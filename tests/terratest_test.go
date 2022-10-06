package test

import (
	"fmt"
	"os"
	"testing"

	iassert "github.com/cgascoig/intersight-simple-go/assert"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestFull(t *testing.T) {
	//========================================================================
	// Setup Terraform options
	//========================================================================

	// Generate a unique name for objects created in this test to ensure we don't
	// have collisions with stale objects
	uniqueId := random.UniqueId()
	instanceName := fmt.Sprintf("test-policies-syslog-%s", uniqueId)

	// Input variables for the TF module
	vars := map[string]interface{}{
		"intersight_keyid":         os.Getenv("IS_KEYID"),
		"intersight_secretkeyfile": os.Getenv("IS_KEYFILE"),
		"name":                     instanceName,
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./full",
		Vars:         vars,
	})

	//========================================================================
	// Init and apply terraform module
	//========================================================================
	defer terraform.Destroy(t, terraformOptions) // defer to ensure that TF destroy happens automatically after tests are completed
	terraform.InitAndApply(t, terraformOptions)
	moid := terraform.Output(t, terraformOptions, "moid")
	assert.NotEmpty(t, moid, "TF module moid output should not be empty")

	//========================================================================
	// Make Intersight API call(s) to validate module worked
	//========================================================================

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedJSONTemplate := `
{
	"Name":        "{{ .name }}",
	"Description": "{{ .name }} NTP Policy.",

	"LocalClients": [
        {
          "ClassId": "syslog.LocalFileLoggingClient",
          "MinSeverity": "warning",
          "ObjectType": "syslog.LocalFileLoggingClient"
        }
	],
	"RemoteClients": [
        {
          "ClassId": "syslog.RemoteLoggingClient",
          "Enabled": true,
          "Facility": "",
          "Hostname": "198.18.5.14",
          "MinSeverity": "warning",
          "ObjectType": "syslog.RemoteLoggingClient",
          "Port": 514,
          "Protocol": "udp",
          "VrfName": ""
        },
        {
          "ClassId": "syslog.RemoteLoggingClient",
          "Enabled": true,
          "Facility": "",
          "Hostname": "198.18.5.15",
          "MinSeverity": "warning",
          "ObjectType": "syslog.RemoteLoggingClient",
          "Port": 514,
          "Protocol": "udp",
          "VrfName": ""
        }
	]
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/syslog/Policies/%s", moid), expectedJSONTemplate, vars)
}
