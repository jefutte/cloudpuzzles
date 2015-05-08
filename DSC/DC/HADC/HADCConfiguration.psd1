@{
    AllNodes = @(

        @{
            Nodename = "dc01"
            Role = "Primary DC"
            DomainName = "cloudpuzzles.net"
            PSDscAllowPlainTextPassword = $true
	        RetryCount = 20 
	        RetryIntervalSec = 30 
        },

        @{
            Nodename = "dc02"
            Role = "Replica DC"
            DomainName = "sva-dscdom.nttest.microsoft.com"
            PSDscAllowPlainTextPassword = $true
	        RetryCount = 20 
	        RetryIntervalSec = 30 
        }
    )
}