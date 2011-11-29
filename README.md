transmissionrb
==============
A simple Ruby class to work with Transmission's HTTP RPC interface. Tested on OSX. Pretty expiremental, not alot of error handling, but enough to demonstrate how to work with the API.

Examples
--------

Initialize default, no auth

    t = Transmission.new

    ..and with auth

        t = Transmission.new(:user => 'username', :pass => 'password')

        Get all tracked torrents (anything that is in the Transmission interface will be returned here)

            t.all #=> [{"name"=>"Torrent Name 1", "rateDownload"=>0, "id"=>98, "peersSendingToUs"=>0, "peersConnected"=>0, "status"=>0, "percentDone"=>1}, {"name"=>"Torrent Name 2", "rateDownload"=>0, "id"=>99, "peersSendingToUs"=>0, "peersConnected"=>0, "status"=>0, "percentDone"=>1}]
