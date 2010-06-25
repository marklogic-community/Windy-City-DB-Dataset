xquery version "1.0-ml";

import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

let $config := admin:get-configuration()
let $forest-name := "windy-"
let $database-name := "windy-"
let $xdbc-server-name := "windy-xdbc-"
let $http-server-name := "windy-"

let $http-server-root := '/tmp/marklogic/'

let $groupid := admin:group-get-id($config, "Default")

return (
for $i in (1, 2, 3, 4, 5, 6)
    let $forest-name := concat($forest-name, $i)
    let $database-name := concat($database-name, $i)
    let $http-server-name := concat($http-server-name, $i)
    let $xdbc-server-name := concat($xdbc-server-name, $i)
    let $xdbc-server-port := $xdbc-server-port + $i
    let $http-server-port := $xdbc-server-port + $i

    return ( 
        try {
            let $appserver-id := admin:appserver-get-id($config, $groupid, $http-server-name)
            let $appserver-delete-config := admin:appserver-delete($config, $appserver-id)
            let $status := admin:save-configuration-without-restart($appserver-delete-config)
            return string-join(("Succesfully deleted appserver: ",$http-server-name)," ")
        } catch ($e) {
            $e
        },
        try {
            let $appserver-id := admin:appserver-get-id($config, $groupid, $xdbc-server-name)
            let $appserver-delete-config := admin:appserver-delete($config, $appserver-id)
            let $status := admin:save-configuration-without-restart($appserver-delete-config)
            return string-join(("Succesfully deleted xdbc server: ",$xdbc-server-name)," ")
        } catch ($e) {
            $e
        },
        try {
            let $db-id := admin:database-get-id($config, $database-name)
            let $database-delete-config := admin:database-delete($config, $db-id)
            let $status := admin:save-configuration-without-restart($database-delete-config)
            return string-join(("Succesfully deleted database: ",$database-name)," ")
        } catch ($e) {
            $e
        },
        try {
            let $forest-id := admin:forest-get-id($config, $forest-name)
            let $forest-delete-config := admin:forest-delete($config, $forest-id, true())
            let $status := admin:save-configuration-without-restart($forest-delete-config)
            return string-join(("Succesfully deleted forest: ",$forest-name)," ")
        } catch ($e) {
            $e
        }
    )

, admin:restart-hosts((xdmp:host()) )
)
