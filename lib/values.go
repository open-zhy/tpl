package lib

import (
	"github.com/imdario/mergo"
	"github.com/pkg/errors"
	"gopkg.in/yaml.v2"
)

func AssignValuesFromFile(fileName string, values *map[string]interface{}) (err error) {
	fileValues := map[string]interface{}{}
	valuesBytes, err := getFileContent(fileName)
	if err != nil {
		return errors.Wrapf(err, "cannot parse values from %s", fileName)
	}

	err = yaml.Unmarshal(valuesBytes, &fileValues)
	if err != nil {
		return errors.Wrapf(err, "cannot parse yaml file %s", fileName)
	}

	return mergo.Merge(values, fileValues)
}
