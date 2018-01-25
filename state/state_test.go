package state

import (
	"fmt"
	"testing"
)

func TestAdd(t *testing.T) {
	// given
	inputJSON := `{
		"module": {
			"cluster_triton_TestCluster1": {
				"name": "TestCluster1"
			}
		}
	}`
	jsonBytes := []byte(inputJSON)
	testState, err := New("TestState", jsonBytes)
	if err != nil {
		t.Errorf("Error parsing JSON: %s", err)
		return
	}

	// when
	expectedKey := "cluster_triton_TestCluster2"
	expectedName := "TestCluster2"
	err = testState.Add(fmt.Sprintf("module.%s", expectedKey), map[string]string{
		"name": expectedName,
	})
	if err != nil {
		t.Errorf("Error adding state: %s", err)
		return
	}

	fmt.Println(string(testState.Bytes()))

	// then
	clusterMap, err := testState.Clusters()
	if err != nil {
		t.Errorf("Error getting clusters: %s", err)
		return
	}

	clusterKey, ok := clusterMap[expectedName]
	if !ok {
		t.Errorf("%s not found in cluster map", expectedName)
		return
	}

	if clusterKey != expectedKey {
		t.Errorf("Expected %q, found %q", expectedKey, clusterKey)
		return
	}
}
