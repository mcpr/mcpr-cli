package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"io"
	"net/http"
	"net/url"
	"os/exec"
	"strconv"

	"time"

	"encoding/json"

	"github.com/Masterminds/semver"
	"github.com/briandowns/spinner"
	"github.com/urfave/cli"
)

func moveFile(in, out string) {
	err := os.Rename(in, out)

	if err != nil {
		fmt.Println(err)
		return
	}
}

func downloadFile(filepath string, url string) (err error) {
	fmt.Println("Downloading...")

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
		return err
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

func buildJava(serverVersion string) {
	fmt.Println("Building... This will take a while.")
	fmt.Println("Go grab a cup of coffee while you wait!")
	s := spinner.New(spinner.CharSets[9], 100*time.Millisecond)
	s.Start()
	cmdPrep := "cd tmp && /usr/bin/java -jar BuildTools.jar --rev " + serverVersion
	cmd := exec.Command("bash", "-c", cmdPrep)
	err := cmd.Run()
	if err != nil {
		fmt.Println(err)
	}
	s.Stop()
	fmt.Println("Build complete.")
}

func setupBuildTools(serverType, serverVersion string) {
	createTmp("tmp")
	downloadFile("tmp/BuildTools.jar", "https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar")
	buildJava(serverVersion)
	moveFile("tmp/"+serverType+"-"+serverVersion+".jar", "server.jar")

	os.RemoveAll("tmp")
}

func setup(ver, serverType string) {
	v, err := semver.NewVersion(ver)
	if err != nil {
		fmt.Println("The version", ver, "doesn't seem to be valid. Are you sure that you specified a valid version?")
		os.Exit(1)
	}

	fmt.Println("Starting setup...")
	fmt.Println("Server Type:", serverType)
	fmt.Println("Minecraft Version:", v)

	switch {
	case serverType == "spigot":
		setupBuildTools(serverType, ver)
	case serverType == "craftbukkit":
		setupBuildTools(serverType, ver)
	case serverType == "vanilla":
		downloadFile("server.jar", "https://s3.amazonaws.com/Minecraft.Download/versions/"+ver+"/minecraft_server."+ver+".jar")
	default:
		fmt.Println("The server type", serverType, " is not supported.")
	}

	fmt.Println("All done! Run java -jar server.jar to start your server!")
}

type ResourceArray []struct {
	Name string `json:"name"`
	Tag  string `json:"tag"`
	ID   int    `json:"id"`
}

type Resource struct {
	External bool `json:"external"`
	File     struct {
		Type     string `json:"type"`
		Size     int    `json:"size"`
		SizeUnit string `json:"sizeUnit"`
		URL      string `json:"url"`
	} `json:"file"`
	Versions []struct {
		ID int `json:"id"`
	} `json:"versions"`
	Updates []struct {
		ID int `json:"id"`
	} `json:"updates"`
	Name    string `json:"name"`
	Tag     string `json:"tag"`
	Version struct {
		ID int `json:"id"`
	} `json:"version"`
	Author struct {
		ID int `json:"id"`
	} `json:"author"`
	Category struct {
		ID int `json:"id"`
	} `json:"category"`
	ID int `json:"id"`
}

func spigotAPIClientArray(endpoint string) ResourceArray {
	spigotAPI := "https://api.spiget.org/v2"

	url := fmt.Sprintf(spigotAPI + endpoint)
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

func spigotAPIClient(endpoint string) Resource {
	spigotAPI := "https://api.spiget.org/v2"

	url := fmt.Sprintf(spigotAPI + endpoint)
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
	spigotBaseURL := "https://www.spigotmc.org/"

	safeID := url.QueryEscape(id)
	endpoint := "/resources/" + safeID

	req := spigotAPIClient(endpoint)
	url := spigotBaseURL + req.File.URL
	if req.File.Type == "external" {
		fmt.Println("This plugin seems to be from an external source. Please visit the following site to download it:", url)
		os.Exit(1)
	}
	if req.File.Type != ".jar" {
		fmt.Println("This resouce is not a .jar file. Are you sure it is actually a plugin?")
		os.Exit(1)
	}
	fmt.Println("Installing plugin", req.Name+"...")

	size := strconv.Itoa(req.File.Size)
	fmt.Println("Download Size:", size+req.File.SizeUnit)

	downloadLocation := "plugins/" + req.Name + ".jar"
	createTmp("plugins")
	downloadFile(downloadLocation, url)

	fmt.Println("Installation complete! Restart your Minecraft server now!")
}

func searchPlugins(name string) {
	fmt.Println("Searching for plugin", name+"...")

	safeName := url.QueryEscape(name)
	endpoint := "/search/resources/" + safeName

	req := spigotAPIClientArray(endpoint)
	fmt.Println(req)

	for i := 1; i < len(req); i += 4 {
		v := req[i]
		fmt.Println("\n\nName:", v.Name, "\nID:", v.ID, "\nDescription:", v.Tag, "\nInstall Command: mc install", v.ID)
	}
}

func main() {
	vb, err := ioutil.ReadFile("version.txt")
	if err != nil {
		fmt.Print(err)
	}
	version := string(vb)
	app := cli.NewApp()

	serverType := "vanilla"
	ver := "1.11.2"
	app.Name = "mc"
	app.Description = "A CLI for setting up and controlling Minecraft servers."
	app.Version = version
	app.Commands = []cli.Command{
		{
			Name:    "setup",
			Aliases: []string{"s"},
			Usage:   "Setup a minecraft server - mc setup [servertype] [version]",
			Action: func(c *cli.Context) error {
				if c.Args().Get(0) != "" {
					serverType = c.Args().Get(0)
				}
				if c.Args().Get(1) != "" {
					ver = c.Args().Get(1)
				}

				setup(ver, serverType)
				return nil
			},
		},
		{
			Name:    "install",
			Aliases: []string{"i"},
			Usage:   "Install a plugin or plugins - mc install [plugin]",
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
			Usage:   "Search plugins - mc search [plugin]",
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
	}

	app.Run(os.Args)
}
