set working-directory := 'src'

watch: clean
  mkdir ../rendered
  while true; do \
    ls ./*.md | entr -d true; \
    for file in `ls ./*.md`; do \
      pandoc $file \
        -V geometry:margin=1in \
        -o ../rendered/`basename $file .md`.pdf; \
    done; \
  done

build: clean
  mkdir ../rendered
  for file in `ls ./*.md`; do \
    pandoc $file -V geometry:margin=1in -o ../rendered/`basename $file .md`.pdf; \
  done

clean:
  rm -rf ../rendered
