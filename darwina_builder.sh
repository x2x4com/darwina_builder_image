#!/bin/bash


source_dir='.'
base_tag='iteringops/darwinia-builder'
dingding_token=$DINGDING_TOKEN
dingding_url="https://oapi.dingtalk.com/robot/send?access_token=${dingding_token}"

[[ "${1}x" == "-sx" ]] && silent=1 || silent=0

day_tag=$(date +%Y%m%d)

o() {
    [[ $silent -eq 0 ]] && echo $1
}

dt() {
    if [[ "${dingding_token}x" != "x" ]]
    then
        local dingding_ret=$(curl -s ${dingding_url} -H 'Content-Type: application/json' \
    -d "
    {
        \"msgtype\": \"text\",
        \"text\": {
            \"content\": \"[DarwinaBuilderImage] - [${day_tag}]: ${1}\"
        }
    }
    ")
    o "Dingding ret: $dingding_ret"
    fi
}

dt "${day_tag} Starting build darwina base image"

if [ -f "${source_dir}/tags.info" ]
then
    if [ $(grep -c ${day_tag} ${source_dir}/tags.info) -gt 0 ]
	then
		# 这不是第一次更新，累加，找最大的
		before_tag=$(grep ${day_tag} ${source_dir}/tags.info | sort -r | head -1)
		o "before tag: ${before_tag}"
		let tag=before_tag+1
	else
		tag="${day_tag}01"
	fi
else
    o "tag file not existed, let create it."
    tag="${day_tag}01"
    echo $tag > ${source_dir}/tags.info
fi

o "tag now: ${tag}"

cd $source_dir

if [[ $silent -eq 0 ]]
then
	docker build . -t ${base_tag}:${tag}
else
    docker build . -t ${base_tag}:${tag} 2>&1 >/dev/null
fi
if [[ $? -eq 0 ]]
then
	o "save tag"
	echo $tag >> ${source_dir}/tags.info
else
    echo "${base_tag}:${tag} build failed"
    exit 1
fi

# 运行一下，输出信息

cargo_info=$(docker run --rm ${base_tag}:${tag} cargo version)
rustc_info=$(docker run --rm ${base_tag}:${tag} rustc -V)

dt "Docker build success.\nCargo: ${cargo_info}\nRustc: ${rustc_info}\n\nStarting push image to dockerhub"
# 推送docker hub
if [[ $silent -eq 0 ]]
then
    docker push ${base_tag}:${tag}
else
    docker push ${base_tag}:${tag} 2>&1 >/dev/null
fi
if [[ $? -eq 0 ]]
then
	dt "Image: ${base_tag}:${tag} pushed"
else
	dt "Push failed"
fi
