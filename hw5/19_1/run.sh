#!/bin/bash - 
#===============================================================================
#
#          FILE: run.sh
# 
#         USAGE: ./run.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Jianfeng Jia (), jianfeng.jia@gmail.com
#  ORGANIZATION: ics.uci.edu
#       CREATED: 02/07/2014 09:20:33 PST
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

bundle install
bundle exec ruby 19_1.rb $1

