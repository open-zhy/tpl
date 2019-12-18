package lib

import (
	"github.com/pkg/errors"
	"log"
	"os"
	"path/filepath"
)

func FilePathWalkDir(root string) ([]string, error) {
	var files []string
	err := filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			log.Fatal(errors.Wrapf(err, "unable to read directory %s", root))

			return err
		}

		if !info.IsDir() {
			files = append(files, path)
		}
		return nil
	})
	return files, err
}