narm.geojson:
	curl -L 'https://mapsengine.google.com/map/kml?mid=zIPGfIU5JOj8.kcv-uCGATvaA&lid=zIPGfIU5JOj8.kG6lyMjYq-cs' \
	| togeojson \
	| jq '{type: "FeatureCollection", features: .features | map(del(.properties.styleUrl, .properties.styleHash))}' \
	> narm.geojson

