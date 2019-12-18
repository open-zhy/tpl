package cmd

import (
	"fmt"
	"github.com/open-zhy/tpl/lib"
	"github.com/spf13/cobra"
	"log"
)

var (
	files       []string
	directories []string
	separator   string
	fileValues  string
)

func init() {
	rootCmd.AddCommand(resolveCmd)

	resolveCmd.PersistentFlags().StringArrayVarP(&files, "files", "f", []string{}, "files to resolve")
	resolveCmd.PersistentFlags().StringArrayVarP(&directories, "directories", "d", []string{}, "directories to scan")
	resolveCmd.PersistentFlags().StringVarP(&separator, "separator", "t", "", "line break separator between each resolved")
	resolveCmd.PersistentFlags().StringVar(&fileValues, "values", "", "yaml file that has all values to apply")
}

var resolveCmd = &cobra.Command{
	Use:   "resolve",
	Short: "resolve a template directory or file",
	Run: func(cmd *cobra.Command, args []string) {
		// The values to pass to the template,
		// it's just empty since no --set neither --values has been set
		values := map[string]interface{}{}

		if fileValues != "" {
			if err := lib.AssignValuesFromFile(fileValues, &values); err != nil {
				// @todo: handle errors, this can be skipped and use empty default value
				// for now we stop the execution
				log.Fatalf("error: cannot set .Values from %s: %s", fileValues, err)
			}
		}

		// scan all directories that are requested
		for _, dir := range directories {
			dirFilesInner, err := lib.FilePathWalkDir(dir)
			if err == nil {
				files = append(files, dirFilesInner...)
			}

			// @todo: handle errors, for now we just mute any
			// errors in this process
		}

		// construct values to pass into resolver
		rValues := struct {
			Values interface{}
		}{
			Values: values,
		}

		// resolving all specified files + ones in directories
		for _, file := range files {
			if err := lib.ResolveFile(file, rValues); err != nil {
				log.Println(err)
				continue
			}

			fmt.Println(separator)
		}
	},
}
