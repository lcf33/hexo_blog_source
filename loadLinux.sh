#/bin/bash
# filedir:hexo_log_source

da=1042 #1020天前开始写博客

for i in `ls ../linux`;do
	title=`echo $i|awk -F. '{print $1}'`
	hexo new $title
	
	#sed -i 's/tags:/tags: tech,Linux/' source/_posts/$i
	sed -i '5d' source/_posts/$i
	echo '- tech'  >> source/_posts/$i
	echo '- Linux' >> source/_posts/$i
	echo '---'     >> source/_posts/$i
	
	date=`date -d "-${da} day" +%Y-%m-%d`
	da=$((da-2))
	
	sed -i "s/date.*/date: ${date}/" source/_posts/$i

	echo '' >> source/_posts/$i
	
	num=`head -20 ../linux/$i | awk '{print NR,$0}' | grep '## ' | head -1 |awk '{print $1}'`
	((num=num-1))

	awk -vt1=$num 'NR<t1' ../linux/$i >> source/_posts/$i
	echo ''            >> source/_posts/$i
	echo '<!--more-->' >> source/_posts/$i
	echo ''            >> source/_posts/$i
	awk -vt1=$num 'NR>t1' ../linux/$i >> source/_posts/$i
done