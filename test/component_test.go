package test

import (
	"context"
	"testing"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/eks"
	"github.com/cloudposse/test-helpers/pkg/atmos"
	helper "github.com/cloudposse/test-helpers/pkg/atmos/component-helper"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type ComponentSuite struct {
	helper.TestSuite
}

func (s *ComponentSuite) TestBasic() {
	const component = "eks/addon/cloudwatch/basic"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)
	assert.NotNil(s.T(), options)

	// Get the EKS cluster ID from the dependency
	eksOptions := s.GetAtmosOptions("eks/cluster", stack, nil)
	clusterID := atmos.Output(s.T(), eksOptions, "eks_cluster_id")
	require.NotEmpty(s.T(), clusterID, "EKS cluster ID should not be empty")

	// Create AWS EKS client
	awsConfig, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(awsRegion))
	require.NoError(s.T(), err, "Failed to load AWS config")

	eksClient := eks.NewFromConfig(awsConfig)

	// Verify the addon exists and is active
	addonName := "amazon-cloudwatch-observability"
	describeAddonOutput, err := eksClient.DescribeAddon(context.Background(), &eks.DescribeAddonInput{
		ClusterName: &clusterID,
		AddonName:   &addonName,
	})
	require.NoError(s.T(), err, "Failed to describe EKS addon")
	assert.Equal(s.T(), "ACTIVE", string(describeAddonOutput.Addon.Status), "Addon should be in ACTIVE state")

	// Verify addon version
	expectedVersion := "v2.5.0-eksbuild.1"
	assert.Equal(s.T(), expectedVersion, *describeAddonOutput.Addon.AddonVersion, "Addon version should match expected version")

	s.DriftTest(component, stack, nil)
}

func (s *ComponentSuite) TestEnabledFlag() {
	const component = "eks/addon/cloudwatch/disabled"
	const stack = "default-test"
	s.VerifyEnabledFlag(component, stack, nil)
}

func (s *ComponentSuite) SetupSuite() {
	s.TestSuite.InitConfig()
	s.TestSuite.Config.ComponentDestDir = "components/terraform/eks/addon"
	s.TestSuite.SetupSuite()
}

func TestRunSuite(t *testing.T) {
	suite := new(ComponentSuite)
	suite.AddDependency(t, "vpc", "default-test", nil)
	suite.AddDependency(t, "eks/cluster", "default-test", nil)
	helper.Run(t, suite)
}
