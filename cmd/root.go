package cmd

import (
	"github.com/spf13/cobra"
	"log"
)

var (
	Version = "0.0.1"
	Build   = "unknown"
)

var rootCmd = &cobra.Command{
	Use:   "tpl",
	Short: "cli template resolver",
	Run: func(cmd *cobra.Command, args []string) {
		_ = cmd.Usage()
	},
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		log.Fatalf("exited with error: %s", err)
	}
}
