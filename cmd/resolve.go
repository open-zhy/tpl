package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
)

var (
	files []string
)

func init() {
	rootCmd.AddCommand(resolveCmd)
}

var resolveCmd = &cobra.Command{
	Use: "resolve",
	Short: "resolve a template directory or file",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("resolving...")
	},
}