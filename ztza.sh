#!/bin/env bash

mkdir ztza
cd ztza

for i in {1..344}; do
	wget --tries=10 "https://online.fliphtml5.com/kjjlu/ztza/files/large/$i.webp" 
done

cd ..