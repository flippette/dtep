build:
  mkdir rendered
  for file in `ls src/*.md`; do \
    pandoc $file -V geometry:margin=1in -o rendered/`basename $file .md`.pdf; \
  done

clean:
  rm -rf rendered
