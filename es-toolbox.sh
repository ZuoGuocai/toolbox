#!/usr/bin/env bash
# Author: zuoguocai@126.com
# Description: toolbox for es

#====================参数区 begin ====================
A=`tput blink`
B=`tput sgr0`
week_num=`date +%w`
week_array=(日 一 二 三 四 五 六)
WEEK=${week_array[$week_num]}
DATE=`date +%F`



readonly backup_path=/data_backup
readonly index_suffix=$(date +%m.%d -d "-1 days")
readonly es_url="http://127.0.0.1:9200"
#====================参数区 end ====================


#====================backup  begin ====================
function backup_template(){
#获取所有的templates
temp_name=$(curl ${es_url}/_cat/templates?format=json|jq .[].name -r)

for temp in ${temp_name}
do
	#备份所有的templates
	elasticdump --input=${es_url}/${temp}   --output=${backup_path}/${temp}-templates.json --type=template

done
}



function backup_index(){
#获取所有的index
index_name=$(curl ${es_url}/_cat/indices/*${index_suffix}?format=json|jq .[].index -r)

for index in ${index_name}
do
	elasticdump --input=${es_url}/${index}   --output=${backup_path}/${index}-mapping.json --type=mapping
done
}

function backup_data(){
#获取昨天所有的index
index_name=$(curl ${es_url}/_cat/indices/*${index_suffix}?format=json|jq .[].index -r)

for index in ${index_name}
do
        elasticdump --input=${es_url}/${index}   --output=${backup_path}/${index}-data.json --type=data  --limit 1000
done
}


#backup_template
#backup_index
#backup_data



function restore_data(){

	elasticdump  --output=${es_url}/${1}  --input=/${backup_path}/${1}.json   --type=data

}
#restore_data "xxx"

#====================backup  end ====================



#====================diagnostic area  begin ====================

function query_status(){
	curl -s ${es_url}/_cluster/health/|jq
	curl -s ${es_url}/_cat/nodes
}


function diag_red(){
	# 检查集群状态，查看是否有节点丢失，有多少分片无法分配
	curl -s  ${es_url}/_cluster/health/|jq
	# 检查索引级别，找到红色的索引
	curl -s ${es_url}/_cluster/health?level=indices
	curl -s ${es_url}/_cat/indices?v&health=red
	# 查看索引的分片
	curl -s ${es_url}/_cluster/health?level=shards

	# Explain 变红的原因
	curl -s ${es_url}/_cluster/allocation/explain
}

function diag_unassigned(){
	curl -XGET ${es_url}/_cat/shards?h=index,shard,prirep,state,unassigned.reason| grep UNASSIGNED
	curl -XGET ${es_url}/_cluster/allocation/explain?pretty
}

function es_setting(){
	# 打开allocation
curl -X PUT "${es_url}/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'
{
    "transient" : {
        "cluster.routing.allocation.enable" : "all"
    }
}
'
}

#====================diagnostic area  end ====================



#==================== menu begin =========================
menu(){
clear
cat <<-EOF
*************************************************************************
*                                                                       *
*    $A                    【  ES 运维工具  】                           $B *
*                                                                       *
*        1.   查询集群状态                                              *
*        2.   诊断 red shards                                           *
*        3.   诊断 unassigned                                           *
*        4.   备份 templates                                            *
*        5.   备份 mapping                                              *
*        6.   备份 data                                                 *
*        7.   恢复 data                                                 *
*        q.   给朕退下                                                  *
*        h.   获得上仙的帮助                                            *
*                                                                       *
*                                                                       *
*                                                                       *
*              今天是$DATE                 周$WEEK                    *
*                                                                       *
*                                                                       *
*************************************************************************
EOF
}
#====================== menu end ============================


#=======================prompt begin ========================
while true
do
	menu
	read -p  "请选择OPS:"  choice
	case ${choice} in
	1)
		echo ""
		query_status

		echo ""
	;;
	2)
		echo "开始诊断..."
		diag_red
		echo ""
	;;
	3)
		echo "开始诊断..."
		diag_unassigned
		echo ""
	;;


	4)
		echo "开始备份..."
		backup_template
		echo ""
	;;
	5)
		echo "开始备份..."
		backup_index
		echo ""
	;;
	6)
		echo "开始备份..."
		backup_data
	;;
	7)
		echo "开始恢复..."
		#restore_data 
		echo ""
	;;

	q|quit|exit)
 		exit
	;;

	h)
	cat <<-__EOF__
		1. 请阅读后使用
		2. 请阅读后使用

	__EOF__

	;;

	*)
		 echo "Error"
	;;
	esac

done
#=======================prompt end =======================
