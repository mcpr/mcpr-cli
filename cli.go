package main

import (
	"fmt"
	"os"

	"io"
	"net/http"

	"os/exec"

	"time"

	semver "github.com/Masterminds/semver"
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
	fmt.Println("Download complete!")

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

func main() {
	app := cli.NewApp()

	serverType := "vanilla"
	ver := "1.11.2"
	app.Name = "mc"
	app.Description = "A CLI for setting up and controlling Minecraft servers."
	app.Version = "0.0.1"
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

				v, err := semver.NewVersion(ver)
				if err != nil {
					fmt.Println("The version", ver, "doesn't seem to be valid. Are you sure that you specified a valid version?")
					return nil
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
				return nil
			},
		},
	}

	app.Run(os.Args)
}
