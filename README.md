<p align="center" width="100%">
    <img width="70%" src="./gitfigures/rawhash-preview.png">
</p>

# Overview

RawHash (and RawHash2) is a hash-based mechanism to map raw nanopore signals to a reference genome in real-time. To achieve this, it 1) generates an index from the reference genome and 2) efficiently and accurately maps the raw signals to the reference genome such that it can match the throughput of nanopore sequencing even when analyzing large genomes (e.g., human genome.

Below figure shows the overview of the steps that RawHash takes to find matching regions between a reference genome and a raw nanopore signal.

<p align="center" width="100%">
    <img width="50%" src="./gitfigures/overview.png">
</p>

To efficiently identify similarities between a reference genome and reads, RawHash has two steps, similar to regular read mapping tools, 1) indexing and 2) mapping. The indexing step generates hash values from the expected signal representation of a reference genome and stores them in a hash table. In the mapping step, RawHash generates the hash values from raw signals and queries the hash table generated in the indexing step to find seed matches. To map the raw signal to a reference genome, RawHash performs chaining over the seed matches.

RawHash can be used to map reads from **FAST5, POD5, SLOW5, or BLOW5** files to a reference genome in sequence format.

RawHash performs real-time mapping of nanopore raw signals. When the prefix of reads can be mapped to a reference genome, RawHash will stop mapping and provide the mapping information in PAF format. We follow the similar PAF template used in [UNCALLED](https://github.com/skovaka/UNCALLED) and [Sigmap](https://github.com/haowenz/sigmap) to report the mapping information.

# Recent changes

* We have integrated a new overlapping mechanism along with its presets, for our new mechanism, called **Rawsamble**. Please see below the corresponding section to run Rawsamble (i.e., overlapping) with RawHash.

* We came up with a better and more accurate quantization mechanism in RawHash2. The new quantization mechanism dynamically arranges the bucket sizes that each signal value is quantized depending on the normalized distribution of the signal values. **This provides significant improvements in both accuracy and performance.**

* We have integrated the signal alignment functionality with DTW as proposed in RawAlign (see the citation below). The parameters may still not be highly optimized as this is still in experimental stage. Use it with caution.

* rmap.c is now rmap.cpp (needs to be compiled with C++) due to the recent DTW integration. We are planning to make it a C-compatible implementation again.

* We have released RawHash2, a more sensitive and faster raw signal mapping mechanism with substantial improvements over RawHash. RawHash2 is available within this repository. You can still use the earlier version, RawHash v1, from [this release](https://github.com/CMU-SAFARI/RawHash/releases/tag/v1.0).

* It is now possible to disable compiling HDF5, SLOW5, and POD5. Please check the `Compiling with HDF5, SLOW5, and POD5` section below for details.

# Installation

* Clone the code from its GitHub repository (`--recursive` must be used):

```bash
git clone --recursive https://github.com/CMU-SAFARI/RawHash.git rawhash2
```

* Compile (Make sure you have a C++ compiler and GNU make):

```bash
cd rawhash2 && make
```

If the compilation is successful, the path to the binary will be `bin/rawhash2`.

## Compiling with HDF5, SLOW5, and POD5

We are aware that some of the pre-compiled libraries (e.g., POD5) may not work in your system and you may need to compile these libraries from scratch. Additionally, it may be possible that you may not want to compile any of the HDF5, SLOW5, or POD5 libraries if you are not going to use them. RawHash2 provides a flexible Makefile to enable custom compilation of these libraries.

* It is possible to provide your own include and lib directories for *any* of the HDF5, SLOW5, and POD5 libraries, if you do not want to use the source code or the pre-compiled binaries that come with RawHash2. To use your own include and lib directories you should pass them to `make` when compiling as follows:

```bash
#Provide the path to all of the HDF5/SLOW5/POD5 include and lib directories during compilation
make HDF5_INCLUDE_DIR=/path/to/hdf5/include HDF5_LIB_DIR=/path/to/hdf5/lib \
	 SLOW5_INCLUDE_DIR=/path/to/slow5/include SLOW5_LIB_DIR=/path/to/slow5/lib \
	 POD5_INCLUDE_DIR=/path/to/pod5/include POD5_LIB_DIR=/path/to/pod5/lib

#Provide the path to only POD5 include and lib directories during compilation
make POD5_INCLUDE_DIR=/path/to/pod5/include POD5_LIB_DIR=/path/to/pod5/lib
```

* It is possible to disable compiling *any* of the HDF5, SLOW5, and POD5 libraries. To disable them, you can use the following variables

```bash
#Disables compiling HDF5
make NOHDF5=1

#Disables compiling SLOW5 and POD5
make NOSLOW5=1 NOPOD5=1
```

# Usage

## Getting help

You can print the help message to learn how to use `rawhash2`:

```bash
rawhash2
```

or 

```bash
rawhash2 -h
```

## Indexing
Indexing is similar to minimap2's usage. We additionally include the pore models located under ./extern

Below is an example that generates an index file `ref.ind` for the reference genome `ref.fasta` using a certain k-mer model located under `extern` and `32` threads.

```bash
rawhash2 -d ref.ind -p extern/kmer_models/legacy/legacy_r9.4_180mv_450bps_6mer/template_median68pA.model -t 32 ref.fasta
```

Note that you can directly jump to mapping without creating the index because RawHash2 is able to generate the index relatively quickly on-the-fly within the mapping step. However, a real-time genome analysis application may still prefer generating the indexing before the mapping step. Thus, we suggest creating the index before the mapping step.

## Mapping

It is possible to provide inputs as FAST5 files from multiple directories. It is also possible to provide a list of files matching a certain pattern such as `test/data/contamination/fast5_files/Min*.fast5`

* Example usage where multiple files matching a certain the pattern `test/data/contamination/fast5_files/Min*.fast5` and fast5 files inside the `test/data/d1_sars-cov-2_r94/fast5_files` directory are inputted to rawhash2 using `32` threads and the previously generated `ref.ind` index:

```bash
rawhash2 -t 32 ref.ind test/data/contamination/fast5_files/Min*.fast5 test/data/d1_sars-cov-2_r94/fast5_files > mapping.paf
```

* Another example usage where 1) we only input a directory including FAST5 files as set of raw signals and 2) the output is directly saved in a file.

```bash
rawhash2 -t 32 -o mapping.paf ref.ind test/data/d1_sars-cov-2_r94/fast5_files
```

**IMPORTANT** if there are many fast5 files that rawhash2 needs to process (e.g., thousands of them), we suggest that you specify **only** the directories that contain these fast5 files

RawHash2 also provides a set of default parameters that can be preset automatically.

* Mapping reads to a viral reference genome using its corresponding preset:

```
rawhash2 -t 32 -x viral ref.ind test/data/d1_sars-cov-2_r94/fast5_files > mapping.paf
```

* Mapping reads to small reference genomes (<500M bases) using its corresponding preset:

```
rawhash2 -t 32 -x sensitive ref.ind test/data/d4_green_algae_r94/fast5_files > mapping.paf
```

* Mapping reads to large reference genomes (>500M bases) using its corresponding preset:

```
rawhash2 -t 32 -x fast ref.ind test/data/d5_human_na12878_r94/fast5_files > mapping.paf
```

RawHash2 provides another set of default parameters that can be used for very large metagenomic samples (>10G). To achieve efficient search, it uses the minimizer seeding in this parameter setting, which is slightly less accurate than the non-minimizer mode but much faster (around 3X).

```
rawhash2 -t 32 -x faster ref.ind test/data/d5_human_na12878_r94/fast5_files > mapping.paf
```

The output will be saved to `mapping.paf` in a modified PAF format used by [Uncalled](https://github.com/skovaka/UNCALLED).

## Rawsamble (for overlapping and assembly construction)

Our new overlapping mechanism, Rawsamble, is now integrated in RawHash. To create overlaps, you can construct the index from signals and perform overlapping using this index as follows:

```
rawhash2 -x ava-small -p ../../rawhash2/extern/kmer_models/legacy/legacy_r9.4_180mv_450bps_6mer/template_median68pA.model -d ava.ind -t32 test/data/d3_yeast_r94/fast5_files/
```

Then perform overlapping using this index:

```
rawhash2 -x ava-small -t32 ava.ind test/data/d3_yeast_r94/fast5_files/ > ava.paf
```

We provide the following presets for Rawsamble to enable the overlapping mode (shown in the help message):


```bash
Rawsamble Presets:
                 - ava-viral             All-vs-all overlapping for very small genomes such as viral genomes.
                 - ava-small             All-vs-all overlapping for small genomes of size < 500M.
                 - ava-fast              All-vs-all overlapping for large genomes of size > 500M and < 5Gb
                 - ava-faster            All-vs-all overlapping for very large genomes > 5Gb)
```

## Potential issues you may encounter during mapping

It is possible that your reads in fast5 files are compressed with the [VBZ compression](https://github.com/nanoporetech/vbz_compression) from Nanopore. Then you have to download the proper HDF5 plugin from [here](https://github.com/nanoporetech/vbz_compression/releases) and make sure it can be found by your HDF5 library:

```bash
export HDF5_PLUGIN_PATH=/path/to/hdf5/plugins/lib
```

If you have conda you can simply install the following package (`ont_vbz_hdf_plugin`) in your environment and use rawhash2 while the environment is active:

```bash
conda install ont_vbz_hdf_plugin
```
# Reproducing the results

Please follow the instructions in the [README](test/README.md) file in [test](./test/).

# Upcoming Features

* Direct integration with MinKNOW.
* Ability to specify even/odd channels to eject the reads only from these specified channels.
* Please create issues if you want to see more features that can make RawHash2 easily integratable with nanopore sequencers for any use case.

# Citing RawHash, RawHash2, and RawAlign

If you use RawHash in your work, please consider citing the following papers:

```bibtex
@article{firtina_rawhash_2023,
	title = {{RawHash}: enabling fast and accurate real-time analysis of raw nanopore signals for large genomes},
	author = {Firtina, Can and Mansouri Ghiasi, Nika and Lindegger, Joel and Singh, Gagandeep and Cavlak, Meryem Banu and Mao, Haiyu and Mutlu, Onur},
	journal = {Bioinformatics},
	volume = {39},
	number = {Supplement_1},
	pages = {i297-i307},
	month = jun,
	year = {2023},
	doi = {10.1093/bioinformatics/btad272},
	issn = {1367-4811},
	url = {https://doi.org/10.1093/bioinformatics/btad272},
}

@article{firtina_rawhash2_2024,
  title = {{RawHash2: Mapping Raw Nanopore Signals Using Hash-Based Seeding and Adaptive Quantization}},
  author = {Firtina, Can and Soysal, Melina and Lindegger, Joël and Mutlu, Onur},
  journal = {arXiv},
  year = {2024},
  month = may,
  doi = {10.48550/arXiv.2309.05771},
  url = {https://doi.org/10.48550/arXiv.2309.05771},
}

@article{lindegger_rawalign_2023,
  title = {{RawAlign}: {Accurate, Fast, and Scalable Raw Nanopore Signal Mapping via Combining Seeding and Alignment}},
  author = {Lindegger, Joël and Firtina, Can and Ghiasi, Nika Mansouri and Sadrosadati, Mohammad and Alser, Mohammed and Mutlu, Onur},
  journal = {arXiv},
  year = {2023},
  month = oct,
  doi = {10.48550/arXiv.2310.05037},
  url = {https://doi.org/10.48550/arXiv.2310.05037},
}
```

# Acknowledgement

RawHash2 uses [klib](https://github.com/attractivechaos/klib), some code snippets from [Minimap2](https://github.com/lh3/minimap2) (e.g., pipelining, hash table usage, DP and RMQ-based chaining) and the R9.4 segmentation parameters from [Sigmap](https://github.com/haowenz/sigmap). RawHash2 uses the DTW integration as proposed in RawAlign (please see the citation details above).

We thank [Melina Soysal](https://github.com/melina2200) and [Marie-Louise Dugua](https://github.com/MarieSarahLouise) for their feedback to improve the RawHash implementation and test scripts.
