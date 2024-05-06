#!/bin/env bash

mkdir ztza

for i in {1..10}; do
	wget -b "https://online.fliphtml5.com/kjjlu/ztza/files/large/$i.webp" -o "ztza/$i.webp"
done