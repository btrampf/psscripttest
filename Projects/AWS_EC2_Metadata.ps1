#Authenticate with AWS
Set-AwsSsoCredential -Account $ACCOUNTS

#outputs Selected.Amazon.EC2.Model.Reservation objects for instances
$socmas = Get-EC2Instance -ProfileName $ACCOUNTS.profile[0] -Region us-west-2 | Select-Object -Property Instances

$socmas.Instances

$socmas[0].Instances

$socmas[0..10].Instances

$socmas.instances | Select-Object -Property InstanceId

$socmas.instances[0] | Select-Object -Property *

$socmashst02 = $socmas.instances | Where-Object -Property InstanceId -EQ i-0af9e704f8ba0a0ca | Select-Object -Property *

$socmashst02.Name