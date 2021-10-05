tree -dfi --noreport $1 | xargs -I{} mkdir -p $2

cp -R $1/input/ $2/input/
cp -R $1/R/ $2/R/

