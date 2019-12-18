package lib

import (
	"bytes"
	"fmt"
	"github.com/Masterminds/sprig"
	"github.com/pkg/errors"
	"io/ioutil"
	"os"
	"text/template"
)

// getFileContent render a file content in order to make is electable
// for template text
func getFileContent(filename string) ([]byte, error) {
	if _, err := os.Stat(filename); err != nil {
		return []byte{}, errors.Wrapf(err, "unable to resolve %s", filename)
	}

	b, err := ioutil.ReadFile(filename)
	if err != nil {
		return []byte{}, errors.Wrapf(err, "unable to read file %s", filename)
	}

	return b, nil
}

// ResolveFile resolves a file against a set of values
func ResolveFile(filename string, values interface{}) error {
	tplBytes, err := getFileContent(filename)
	if err != nil {
		return err
	}

	// Compile the template
	t := template.Must(
		template.New(filename).Funcs(sprig.TxtFuncMap()).Parse(string(tplBytes)),
	)

	// Run the template, copying the output to the buffer.
	var buff bytes.Buffer
	if err := t.Execute(&buff, values); err != nil {
		return errors.Wrapf(err, "unable to resolve content")
	}

	fmt.Printf("%s\n", buff.String())
	return nil
}
