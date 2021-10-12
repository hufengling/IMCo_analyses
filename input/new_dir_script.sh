cd ..
mkdir -p $2

#copy dir structure of $1 to $2, including $1
tree -dfi --noreport $1 | xargs -I{} mkdir -p $2/{}

#in $2, unnest dirs from copied $1
rsync -vua --delete-after $2/$1/ $2/

#copy repetitive files from $1 to $2
cp -R $1/input/references/ $2/input/
cp -R $1/input/csvs/demographics/ $2/input/csvs/
cp -R $1/input/csvs/idemodata/ $2/input/csvs/
cp -R $1/R/ $2/
