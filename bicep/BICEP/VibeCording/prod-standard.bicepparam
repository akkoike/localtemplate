using './main-standard.bicep'

param Environment = 'prod'
param Location = 'japaneast'
param ProjectName = 'azstd'
param AdminEmail = 'akkoike@microsoft.com'
param VmAdminPassword = readEnvironmentVariable('VM_ADMIN_PASSWORD', 'P@ssw0rd1234!')
