# Handbuch bauen: make   (PDF: handbuch.pdf)
# Die Rohbilder in bilder/roh/ werden als verkleinerte JPG nach bilder/web/ kopiert (nur die, die das Handbuch braucht,
# stehen in bilder/web; hier alle, ist billig).
PNG := $(wildcard bilder/roh/*.png)
JPG := $(patsubst bilder/roh/%.png,bilder/web/%.jpg,$(PNG))
KAP := $(wildcard kapitel/*.tex)

handbuch.pdf: handbuch.tex $(KAP) $(JPG)
	xelatex -interaction=nonstopmode -halt-on-error handbuch.tex >/dev/null
	xelatex -interaction=nonstopmode -halt-on-error handbuch.tex >/dev/null
	xelatex -interaction=nonstopmode -halt-on-error handbuch.tex | tail -3

bilder/web/%.jpg: bilder/roh/%.png
	@mkdir -p bilder/web
	magick $< -resize 1100x -quality 82 $@

clean:
	rm -f handbuch.aux handbuch.log handbuch.out handbuch.toc handbuch.pdf
