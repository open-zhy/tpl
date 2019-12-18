package lib

import (
	"fmt"
	"github.com/ghodss/yaml"
	//"github.com/open-zhy/tpl/yamlmapstr"
	"github.com/pkg/errors"
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

	// file values is in prior
	tempValues := map[string]interface{}{}
	tempValues = mergeMaps(tempValues, fileValues)
	tempValues = mergeMaps(tempValues, *values)

	*values = tempValues

	return nil
}

func mergeMaps(a, b map[string]interface{}) map[string]interface{} {
	out := make(map[string]interface{}, len(a))
	for k, v := range a {
		out[k] = v
	}
	for k, v := range b {
		if v, ok := v.(map[string]interface{}); ok {
			if bv, ok := out[k]; ok {
				if bv, ok := bv.(map[string]interface{}); ok {
					out[k] = mergeMaps(bv, v)
					continue
				} else {
					fmt.Printf("--> no: %s\n, %T", k, out[k])
				}
			}
		}
		out[k] = v
	}
	return out
}
