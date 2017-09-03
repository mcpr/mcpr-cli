package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
	"io/ioutil"

	"io"
	"net/http"
	"net/url"
	"os/exec"
	//"strconv"
	"time"

	"encoding/json"

	"github.com/Masterminds/semver"
	"github.com/briandowns/spinner"
	"github.com/urfave/cli"
	"github.com/fatih/color"
	"os/user"
)

var (
    mcprAPIBaseUrl	string
)

func moveFile(in, out string) {
	err := os.Rename(in, out)

	if err != nil {
		os.Exit(1)
		return
	}
}

func downloadFile(filepath string, url string) (err error) {
	fmt.Println("\nDownloading...")

	s := spinner.New(spinner.CharSets[9], 100*time.Millisecond)
	s.Start()
	// Create the file
	out, err := os.Create(filepath)
	if err != nil {
		return err
	}
	defer out.Close()

	// Get the data
	resp, err := http.Get(url)
	if err != nil {
		color.Set(color.FgRed)
		fmt.Println(err)
		color.Unset()
		return err
	}
	if resp.StatusCode == http.StatusNotFound {
		color.Set(color.FgRed)
		fmt.Println(resp.StatusCode)
		fmt.Println("The file you requested could not be found...")
		color.Unset()
		os.Exit(1)
		
	}
	defer resp.Body.Close()

	// Writer the body to file
	_, err = io.Copy(out, resp.Body)
	if err != nil {
		return err
	}

	s.Stop()

	return nil
}

func createTmp(path string) {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		os.Mkdir(path, os.ModePerm)
	}
}

// RemoveContents removes directory (relative path only)
func RemoveContents(dir string) {
	cmdPrep := "if [ -e " + dir + " ]; then rm -r " + dir + "; fi"
	cmd := exec.Command("bash", "-c", cmdPrep)
	err := cmd.Run()
	if err != nil {
		fmt.Println(err)
	}
}

/**
* Setup Minecraft Server
*/

var tmpName = "mcpr-cli-tmp"

func buildJava(serverVersion string, verbose bool) {
	fmt.Println("Building... This will take a while.")
	fmt.Println("\nGo grab a cup of coffee while you wait!")
	fmt.Println("Or play some Minecraft...")

	s := spinner.New(spinner.CharSets[9], 100*time.Millisecond)
	s.Start()

	cmdArgs := "cd " + tmpName + " && /usr/bin/java -jar BuildTools.jar --rev " + serverVersion
	cmd := exec.Command("bash", "-c", cmdArgs)
	
	if (verbose) {
		cmd.Stdout = os.Stdout
		cmd.Stdin = os.Stdin
		cmd.Stderr = os.Stderr
	}
		
	err := cmd.Run()
	if err != nil {
		fmt.Println(err)
		fmt.Println("Try runing with --verbose for more details.")
		os.Exit(1)
	}

	s.Stop()
	fmt.Println("\nBuild complete.")
}

func setupBuildTools(serverType, serverVersion string, verbose bool) {
	tmpPath, _ := filepath.Abs(tmpName)

	RemoveContents(tmpName)
	createTmp(tmpPath)

	downloadFile(tmpName+"/BuildTools.jar", "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar")
	buildJava(serverVersion, verbose)

	jarPath := tmpPath + "/" + serverType + "-" + serverVersion + ".jar"
	moveFile(jarPath, "server.jar")

	RemoveContents(tmpName)
}

func Ask4confirm() bool {
	var s string

	fmt.Printf("\nDo you agree to the Mojang EULA? (https://account.mojang.com/documents/minecraft_eula) (y/N): ")
	_, err := fmt.Scan(&s)
	if err != nil {
		panic(err)
	}

	s = strings.TrimSpace(s)
	s = strings.ToLower(s)

	if s == "y" || s == "yes" {
		return true
	}
	return false
}

func acceptEula() {
	err := ioutil.WriteFile("eula.txt", []byte("eula=true"), 0644)
	if err != nil {
			log.Fatalln(err)
	}
}

func setup(ver, serverType string, verbose, accept bool) {
	v, err := semver.NewVersion(ver)
	if err != nil {
		fmt.Println("The version", ver, "doesn't seem to be valid. Are you sure that you specified a valid version?")
		os.Exit(1)
	}

	fmt.Println("Starting setup...")
	fmt.Println("\nServer Type:", serverType)
	fmt.Println("Minecraft Version:", v)

	switch {
	case serverType == "spigot" || serverType ==  "craftbukkit":
		setupBuildTools(serverType, ver, verbose)
	case serverType == "vanilla":
		downloadFile("server.jar", "https://s3.amazonaws.com/Minecraft.Download/versions/"+ver+"/minecraft_server."+ver+".jar")
	default:
		fmt.Println("The server type", serverType, " is not supported.")
	}
	
	if (accept){
		acceptEula()
	} else {
		isConfirmed := Ask4confirm()
		if isConfirmed {
			fmt.Println("Yes")
			acceptEula()
		} 
	}
	
	fmt.Println("\n\n\nAll done! Run \"java -jar server.jar\" to start your server!")
}


/**
* Install Plugins
*/

// ResourceArray Spigot resources array
type ResourceArray []struct {
	Description  string `json:"short_description"`
	ID   string    `json:"_id"`
}

// Resource Spigot resource
type Resource struct {
	Versions []struct {
		ID int `json:"id"`
	} `json:"versions"`
	Title    string `json:"title"`
	Description  string `json:"short_description"`
	Version string `json:"latest_version"`
	VersionDate string `json:"latest_version_date"`
	Author  string  `json:"author"`
	ID string `json:"_id"`
}

func mcprAPIClientArray(endpoint string) ResourceArray {
	url := fmt.Sprintf(mcprAPIBaseUrl + endpoint)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		log.Fatal("NewRequest: ", err)
		os.Exit(1)
	}
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal("Do: ", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	var recordArray ResourceArray

	if err := json.NewDecoder(resp.Body).Decode(&recordArray); err != nil {
		log.Println(err)
	}

	return recordArray
}

func mcprAPIClient(endpoint string) Resource {
	url := fmt.Sprintf(mcprAPIBaseUrl + endpoint)
	
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		log.Fatal("NewRequest: ", err)
		os.Exit(1)
	}
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Fatal("Do: ", err)
		os.Exit(1)
	}
	defer resp.Body.Close()

	var record Resource

	if err := json.NewDecoder(resp.Body).Decode(&record); err != nil {
		log.Println(err)
	}
	return record
}

func installPlugin(id string) {
	var safeID = url.QueryEscape(id)
	var version = ""
	var downloadUrl = ""
	
	fmt.Println()
	if (strings.ContainsAny(id, "@")){
		idAndVer := strings.Split(id, "@")
		safeID = url.QueryEscape(idAndVer[0])
		version = url.QueryEscape(idAndVer[1])
	}
	endpoint := "/plugins/" + safeID
	
	req := mcprAPIClient(endpoint)
	var downloadVersion = ""
	
	if (len(version) > 0) {
		downloadVersion = version
	} else {
		downloadVersion = req.Version
	}
	downloadUrl = mcprAPIBaseUrl + "/versions/" + safeID + "/" + downloadVersion + "/download"
	
	color.Set(color.FgCyan)
	fmt.Println("Installing plugin", req.ID + "@" + downloadVersion + "...")
	color.Unset()
	
	downloadLocation := "plugins/" + req.ID + "-" + downloadVersion + ".jar"
	createTmp("plugins")
	downloadFile(downloadLocation, downloadUrl)

	color.Set(color.FgCyan)
	fmt.Println("Installation complete! Restart your Minecraft server now!")
	color.Unset()
}

func searchPlugins(name string) {
	color.Set(color.FgCyan)
	fmt.Println("Searching for plugin", name + "...")

	safeName := url.QueryEscape(name)
	endpoint := "/plugins/search?q=" + safeName
	req := mcprAPIClientArray(endpoint)

	for i := 0; i < len(req); i += 1 {
		color.Set(color.FgGreen)
		v := req[i]
		fmt.Println("\nID:", v.ID, "\nDescription:", v.Description, "\nInstall Command: mcpr install", v.ID)
		color.Unset()
	}

	if (len(req)==0){
		color.Red("\nNo plugins found!")
	} else {
		color.Cyan("\nSearch complete!")
	}
	color.Unset()
}
type Config struct {
    BaseUrl  string `json:"base_url"`
}

func config(){	
	usr, err := user.Current()
    if err != nil {
        log.Fatal(err)
    }
	configFile := usr.HomeDir + "/.mcprconfig.json"

	// create config file if it doesn't already exist
	if _, err := os.Stat(configFile); os.IsNotExist(err) {
		var jsonBlob = []byte(`{"base_url":"https://registry.hexagonminecraft.com/api/v1"}`)
		config := Config{}
		err := json.Unmarshal(jsonBlob, &config)
		if err != nil {
			log.Fatal("opening config file", err.Error())
		}
		configJson, _ := json.Marshal(config)
		
		err = ioutil.WriteFile(configFile, configJson, 0644)
		if err != nil {
			panic(err)
		}
	} else {
		// if config exists, load it
		raw, err := ioutil.ReadFile(configFile)
		if (err != nil){
			panic(err)
		}
		
		var config Config

		json.Unmarshal(raw, &config)
		mcprAPIBaseUrl = config.BaseUrl
	}
}


func setConfig(option string, value string) {
	fmt.Println("This command hasn't been implemented yet...")
	fmt.Println(option + "=" + value)
}
func main() {
	config()
	cliVersion := "0.0.9"
	
	
	
	app := cli.NewApp()

	serverType := "vanilla"
	ver := "1.12.1"
	app.Name = "mcpr"
    app.Usage = "The official MCPR cli!"
	app.Description = "A CLI for setting up and controlling Minecraft servers."
	app.Version = cliVersion
	app.Commands = []cli.Command{
		{
			Name:    "setup",
			Aliases: []string{"s"},
			Usage:   "Setup a minecraft server - mcpr setup [servertype] [version]",
            Flags: []cli.Flag{
                cli.BoolFlag{Name: "verbose, v", Usage: "Show more output"},
                cli.BoolFlag{Name: "accept, a", Usage: "Accept Mojangs EULA"},
            },
			Action: func(c *cli.Context) error {				
				if c.Args().Get(0) != "" {
					serverType = c.Args().Get(0)
				}
				if c.Args().Get(1) != "" {
					ver = c.Args().Get(1)
				}
				verbose := c.Bool("verbose")
				accept := c.Bool("accept")
				fmt.Println("Verbose:", verbose)
				setup(ver, serverType, verbose, accept)
				return nil
			},
		},
		{
			Name:    "install",
			Aliases: []string{"i"},
			Usage:   "Install a plugin or plugins - mcpr install [plugin]",
			Action: func(c *cli.Context) error {
				if c.Args().Get(0) != "" {
					pluginID := c.Args().Get(0)
					installPlugin(pluginID)
				} else {
					fmt.Println("Installing all plugins...")
				}

				return nil
			},
		},
		{
			Name:    "search",
			Aliases: []string{"l"},
			Usage:   "Search plugins - mcpr search [plugin]",
			Action: func(c *cli.Context) error {
				if c.Args().Get(0) != "" {
					pluginName := c.Args().Get(0)
					searchPlugins(pluginName)
				} else {
					fmt.Println("Please specify a plugin.")
				}

				return nil
			},
		},
		{
			Name:    "config",
			Aliases: []string{"c"},
			Usage:   "Set config - mcpr config [key] [value]",
			Action: func(c *cli.Context) error {
				if c.Args().Get(0) != "" && c.Args().Get(1) != ""  {
					key := c.Args().Get(0)
					value := c.Args().Get(1)
					setConfig(key, value)
				} else {
					fmt.Println("\nConfig Options:\nMCPR Base API URL - base_url=" + mcprAPIBaseUrl)
				}

				return nil
			},
		},
		{
			Name:    "start",
			Usage:   "Start Minecraft server - mcpr start",
			Action: func(c *cli.Context) error {
				cmd := exec.Command("java", "-jar", "server.jar", "nogui")
				cmd.Stdout = os.Stdout
				cmd.Stdin = os.Stdin
				cmd.Stderr = os.Stderr
				cmd.Run()
				return nil
			},
		},
	}

	app.Run(os.Args)
}
