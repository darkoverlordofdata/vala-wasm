#!/usr/bin/env coffee
###
## Copyright (c) 2017 Bruce Davidson &lt;darkoverlordofdata@gmail.com&gt;
## Apache 2.0 License
##
##  Phase I - preprocess for valac
##
## Injects reference counting boilerplate into classes that sublcass Object
##
##  <ClassName> : Object
##
###
fs = require 'fs'
path = require 'path'
list = []
options = {}
lcfirst = (str) -> str.charAt(0).toLowerCase() + str.substr(1)
snakeCase = (str) ->  str.replace(/([A-Z])/g, ($0) -> "_"+$0.toLowerCase())
SRC = 'src'

##
## walk the folder, gather list of files
##
walk = (namespace = '') ->
    source = if namespace is "" then "./build/#{SRC}" else "./build/#{SRC}/#{namespace}"
    for file in fs.readdirSync(source)
        switch path.extname(file)

            when '.gs' 
                klass = file.replace('.gs','')
                if klass[0] >='A' && klass[0] <= 'Z'
                    list.push "#{source}/#{file}"
                    name = klass.toLowerCase()
                    options["#{source}/#{file}"] = { 'ext':'gs', 'class': klass, 'name': name, 'namespace': namespace }
                    console.log "#{source}/#{file}"

            when '.vala' 
                klass = file.replace('.vala','')
                if klass[0] >='A' && klass[0] <= 'Z'
                    list.push "#{source}/#{file}"
                    name = klass.toLowerCase()
                    options["#{source}/#{file}"] = { 'ext':'vala', 'class': klass, 'name': name, 'namespace': namespace }
                    console.log "#{source}/#{file}"

            when '.c' then continue
            else # recurse down the tree
                folder = namespace+(if namespace is "" then "" else '/')+file
                if folder.indexOf('.') == -1 then walk(folder)


do ->
    walk()
    require('./boilerplate')[options[file].ext](file, options[file]) for file in list
    
    