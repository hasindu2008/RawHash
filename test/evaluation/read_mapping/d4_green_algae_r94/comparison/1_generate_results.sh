#!/bin/bash

uncalled pafstats -r ../true_mappings.paf --annotate ../uncalled/d4_green_algae_r94_uncalled.paf > d4_green_algae_r94_uncalled_ann.paf 2> d4_green_algae_r94_uncalled.throughput
uncalled pafstats -r ../true_mappings.paf --annotate ../sigmap/d4_green_algae_r94_sigmap.paf > d4_green_algae_r94_sigmap_ann.paf 2> d4_green_algae_r94_sigmap.throughput
uncalled pafstats -r ../true_mappings.paf --annotate ../rawhash/d4_green_algae_r94_rawhash_sensitive.paf > d4_green_algae_r94_rawhash_sensitive_ann.paf 2> d4_green_algae_r94_rawhash_sensitive.throughput
uncalled pafstats -r ../true_mappings.paf --annotate ../rawhash/d4_green_algae_r94_w3_rawhash_sensitive.paf > d4_green_algae_r94_w3_rawhash_sensitive_ann.paf 2> d4_green_algae_r94_w3_rawhash_sensitive.throughput
# uncalled pafstats -r ../true_mappings.paf --annotate ../rawhash/d4_green_algae_r94_w5_rawhash_sensitive.paf > d4_green_algae_r94_w5_rawhash_sensitive_ann.paf 2> d4_green_algae_r94_w5_rawhash_sensitive.throughput


python ../../../../scripts/compare_pafs.py d4_green_algae_r94_uncalled_ann.paf d4_green_algae_r94_sigmap_ann.paf d4_green_algae_r94_rawhash_sensitive_ann.paf > d4_green_algae_r94_rawhash_sensitive.comparison
python ../../../../scripts/compare_pafs.py d4_green_algae_r94_uncalled_ann.paf d4_green_algae_r94_sigmap_ann.paf d4_green_algae_r94_w3_rawhash_sensitive_ann.paf > d4_green_algae_r94_w3_rawhash_sensitive.comparison
# python ../../../../scripts/compare_pafs.py d4_green_algae_r94_uncalled_ann.paf d4_green_algae_r94_sigmap_ann.paf d4_green_algae_r94_w5_rawhash_sensitive_ann.paf > d4_green_algae_r94_w5_rawhash_sensitive.comparison
