#!/bin/bash

pkg=openssl-1.1

comm -12 \
  <(paru -Qmq | sort) \
  <(
    {
      paru -Ssaq --searchby=makedepends "$pkg"
      paru -Ssaq --searchby=checkdepends "$pkg"
    } | sort -u
  )
