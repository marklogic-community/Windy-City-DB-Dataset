xquery version "1.0-ml";

import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";

let $config := admin:get-configuration()
let $forest-name := "windy-"
let $database-name := "windy-"
let $xdbc-server-name := "windy-xdbc-"
let $xdbc-server-port := 10000
let $http-server-name := "windy-"
let $http-server-port := 9000

let $http-server-root := '/tmp/marklogic/'

let $groupid := admin:group-get-id($config, "Default")

return (
for $i in (1, 2, 3, 4, 5, 6)
    let $forest-name := concat($forest-name, $i)
    let $database-name := concat($database-name, $i)
    let $http-server-name := concat($http-server-name, $i)
    let $xdbc-server-name := concat($xdbc-server-name, $i)
    let $xdbc-server-port := $xdbc-server-port + $i
    let $http-server-port := $http-server-port + $i

    return ( 
        try {
                let $forest-create-config := admin:forest-create($config,$forest-name,xdmp:host(),())
                let $status := admin:save-configuration-without-restart($forest-create-config)
                return string-join(("Succesfully created",$forest-name)," ")
        } catch ($e) {
                if (data($e/error:code) eq "ADMIN-DUPLICATENAME") then 
                fn:string-join(("Forest",$forest-name,"exists,","skipping create")," ")
                else $e
        },
        try { 
                let $database-create-config := admin:database-create($config, $database-name, xdmp:database("Security"), xdmp:database("Schemas"))
                let $status := admin:save-configuration-without-restart($database-create-config)
                return string-join(("Succesfully created",$database-name)," ")
        } catch ($e) {
                if (data($e/error:code) eq "ADMIN-DUPLICATENAME") then 
                fn:string-join(("Database",$database-name,"exists,","skipping create")," ")
                else $e
        }, 
        try {
            let $range-index := admin:database-range-element-index("dateTime", "http://marklogic.com/windycity",
                "creation_date", "http://marklogic.com/collation/", fn:false() )
            let $re-config := admin:database-add-range-element-index($config, xdmp:database($database-name), $range-index)
            let $status := admin:save-configuration-without-restart($re-config)
            return "Succesfully added range element index"
        } catch ($e) {
            $e
        }, 
        try {
            let $range-index := admin:database-range-element-index("string", "http://marklogic.com/windycity",
                "tag", "http://marklogic.com/collation/", fn:false() )
            let $re-config := admin:database-add-range-element-index($config, xdmp:database($database-name), $range-index)
            let $status := admin:save-configuration-without-restart($re-config)
            return "Succesfully added range element index"
        } catch ($e) {
            $e
        }, 
        try {
            let $forest-attach-config := admin:database-attach-forest($config,xdmp:database($database-name),xdmp:forest($forest-name))
            let $status := admin:save-configuration-without-restart($forest-attach-config)
            return string-join(("Succesfully attached",$forest-name,"to",$database-name)," ")
        } catch ($e) {
            if (data($e/error:code) eq "ADMIN-DATABASEFORESTATTACHED") then 
            fn:string-join(("Forest",$forest-name,"is already attached to",$database-name,",","skipping attach")," ")
            else $e
        }, 
        try {
            let $appserver-create-config := admin:http-server-create($config, $groupid, $http-server-name, 
                    $http-server-root, $http-server-port, 0, xdmp:database($database-name))
            let $status := admin:save-configuration-without-restart($appserver-create-config)
            return string-join(("Succesfully created",$http-server-name)," ")
        } catch ($e) {
            if (data($e/error:code) eq "ADMIN-PORTINUSE") 
                then fn:string-join(("Port for",$http-server-name,"in use, try changing the port number")," ")
            else (if (data($e/error:code) eq "ADMIN-DUPLICATEITEM") 
                then fn:string-join(("App Server",$http-server-name,"already exists on different port")," ") else $e)
        },
        try {
            let $xdbcserver-create-config := admin:xdbc-server-create($config, $groupid, $xdbc-server-name, 
                    '/', $xdbc-server-port, 0, xdmp:database($database-name))
            let $status := admin:save-configuration-without-restart($xdbcserver-create-config)
            return string-join(("Succesfully created",$xdbc-server-name)," ")
        } catch ($e) {
            if (data($e/error:code) eq "ADMIN-PORTINUSE") 
                then fn:string-join(("Port for",$xdbc-server-name,"in use, try changing the port number")," ")
            else (if (data($e/error:code) eq "ADMIN-DUPLICATEITEM") 
                then fn:string-join(("App Server",$xdbc-server-name,"already exists on different port")," ") else $e)
        }
    )

, admin:restart-hosts((xdmp:host()) )
)
