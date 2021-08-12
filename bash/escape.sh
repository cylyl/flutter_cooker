#!/bin/bash
if [ -z "$1" ]
  then
    echo "Model name not found in arguments";exit 0;
fi
modelName=$1
modelNameLc="${modelName,,}"
#escape single quote
sed 's|\x27|\\\x27|g' dart.a > dart.b
#escape newline
sed -i ':a;N;$!ba;s|\n|\\n\x27\n\x27|g'  dart.b
sed -i "s|$modelName|'+modelName+'|g" dart.b
sed -i "s|$modelNameLc|'+modelNameCamelCase+'|g" dart.b
cat dart.b
