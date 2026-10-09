# Handbuch bauen: make   (PDF: handbuch.pdf)
# Die Rohbilder in bilder/roh/ werden als verkleinerte JPG nach bilder/web/ kopiert (nur die, die das Handbuch braucht,
# stehen in bilder/web; hier alle, ist billig).
PNG := $(wildcard bilder/roh/*.png)
JPG := $(patsubst bilder/roh/%.png,bilder/web/%.jpg,$(PNG))
KAP := $(wildcard kapitel/*.tex)

handbuch.pdf: handbuch.tex $(KAP) $(JPG) | annotate
	xelatex -interaction=nonstopmode -halt-on-error handbuch.tex >/dev/null
	xelatex -interaction=nonstopmode -halt-on-error handbuch.tex >/dev/null
	xelatex -interaction=nonstopmode -halt-on-error handbuch.tex | tail -3

# Beschriftete Fassungen (bilder/annot/, aus bilder/annot.json) haben Vorrang vor den Rohbildern.
.PHONY: annotate
annotate:
	python3 bilder/annotate.py >/dev/null

bilder/web/%.jpg: bilder/roh/%.png bilder/annot.json bilder/annotate.py | annotate
	@mkdir -p bilder/web
	magick $(if $(wildcard bilder/annot/$*.png),bilder/annot/$*.png,$<) -resize 1100x -quality 82 $@

clean:
	rm -f handbuch.aux handbuch.log handbuch.out handbuch.toc handbuch.pdf

# HTML-Fassungen (selbständige Dateien mit eingebetteten Bildern), benötigen bilder/web/*.jpg
html: $(JPG) tex2html.py $(KAP)
	@mkdir -p html
	python3 tex2html.py handbuch > html/handbuch.html
	python3 tex2html.py anleitung > html/installationsanleitung.html
