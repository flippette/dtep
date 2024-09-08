set working-directory := 'src'

build: clean
  mkdir ../rendered
  for file in `ls ./*.md`; do \
    pandoc $file -V geometry:margin=1in -o ../rendered/`basename $file .md`.pdf; \
  done

clean:
  rm -rf ../rendered
