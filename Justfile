build: build-diaries
clean: clean-diaries

build-diaries:
  for file in `ls diaries/*.md`; do \
    pandoc $file -V geometry:margin=1in -o diaries/`basename $file .md`.pdf; \
  done

clean-diaries:
  rm -f diaries/*.pdf
