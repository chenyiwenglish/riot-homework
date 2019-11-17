#!/bin/bash
TMP_PATH=/Users/chenyiwen/Documents/Java/Project/riot-homework/tmp
MAX_FILE_SIZE=300
SPLIT_PREFIX=.part.
RESULT_PREFIX=final.
cd $TMP_PATH
# split file into smaller file
dir=`ls $TMP_PATH | grep -v res.sort`
for file in $dir
do
  line_count=`wc -l $file | awk '{print $1}'`
  if [ $line_count -gt $MAX_FILE_SIZE ]
  then
    echo "$file line count > size, go split"
    split -l $MAX_FILE_SIZE $file $file$SPLIT_PREFIX
  else
    cp $file $file$SPLIT_PREFIX"aa"
  fi
done
# sort file content and write back
dir=`ls $TMP_PATH | grep part`
for file in $dir
do
  if [ -e $file".res" ]
  then
    echo "file.res exist, remove"
    rm $file".res"
  fi
  cat $file | while read line
  do
    echo `echo $line | awk '{print $6}'` >> $file".res"
  done
  cat $file".res" | sort -n > $file".res.sort"
  rm $file
  rm $file".res"
done
# merge all sorted file
file_index=0
dir=`ls $TMP_PATH | grep res.sort`
for file in $dir
do
  mv $file $RESULT_PREFIX$file_index
  break
done
dir=`ls $TMP_PATH | grep res.sort`
for file in $dir
do
  cur_final_file=$RESULT_PREFIX$file_index
  file_index=$(($file_index+1))
  result_final_file=$RESULT_PREFIX$file_index
  file_array=($(awk '{print $1}' $file))
  final_file_array=($(awk '{print $1}' $cur_final_file))
  i=0
  j=0
  p=0
  while [ $i -lt ${#file_array[@]} ] && [ $j -lt ${#final_file_array[@]} ]
  do
    a=${file_array[$i]}
    b=${final_file_array[$j]}
    if [ $a -lt $b ]
    then
      result_file_array[$p]=$a
      i=$(($i+1))
    else
      result_file_array[$p]=$b
      j=$(($j+1))
    fi
    p=$(($p+1))
  done
  while [ $i -lt ${#file_array[@]} ]
  do
    result_file_array[$p]=${file_array[$i]}
    i=$(($i+1))
    p=$(($p+1))
  done
  while [ $j -lt ${#final_file_array[@]} ]
  do
    result_file_array[$p]=${final_file_array[$j]}
    j=$(($j+1))
    p=$(($p+1))
  done
  q=0
  while [ $q -lt ${#result_file_array[@]} ]
  do
    echo ${result_file_array[$q]} >> $result_final_file
    q=$(($q+1))
  done
  rm $file
  rm $cur_final_file
done
# calculate final result
total_line_count=`wc -l $result_final_file | awk '{print $1}'`
res1=$(($total_line_count*90/100))
mills1=`sed -n $res1'p' $result_final_file`
echo "90% of requests return a response in $mills1 ms"
res2=$(($total_line_count*95/100))
mills2=`sed -n $res2'p' $result_final_file`
echo "95% of requests return a response in $mills2 ms"
res3=$(($total_line_count*99/100))
mills3=`sed -n $res3'p' $result_final_file`
echo "99% of requests return a response in $mills3 ms"
rm $result_final_file