**Status**:
Currently, only the implementation of SHAKE256 is publicly available in this repository.
The remaining parts of the SPHINCSLET codebase will be published soon. Stay tuned!

**Citation**:
If you use this work or find it helpful, please cite:
@article{10.1145/3728469,
author = {Deshpande, Sanjay and Lee, Yongseok and Karakuzu, Cansu and Szefer, Jakub and Paek, Yunheung},
title = {SPHINCSLET: An Area-Efficient Accelerator for the Full SPHINCS+ Digital Signature Algorithm},
year = {2025},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
issn = {1539-9087},
url = {https://doi.org/10.1145/3728469},
doi = {10.1145/3728469},
abstract = {This work presents SPHINCSLET, the first fully standard-compliant and area-efficient hardware implementation of the SLH-DSA algorithm, formerly known as SPHINCS+, a post-quantum digital signature scheme. SPHINCSLET is designed to be parameterizable across different security levels and hash functions, offering a balanced trade-off between area efficiency and performance. Existing hardware implementations either feature a large area footprint to achieve fast signing and verification or adopt a coprocessor-based approach that significantly slows down these operations. SPHINCSLET addresses this gap by delivering a 4.7 \texttimes{} reduction in area compared to high-speed designs while achieving a 2.5 \texttimes{} to 5 \texttimes{} improvement in signing time over the most efficient coprocessor-based designs for a SHAKE256-based SPHINCS+ implementation. The SHAKE256-based SPHINCS+ FPGA implementation targeting the AMD Artix-7 requires fewer than 10.8K LUTs for any security level of SLH-DSA. Furthermore, the SHA-2-based SPHINCS+ implementation achieves a 2 \texttimes{} to 4 \texttimes{} speedup in signature generation across various security levels compared to existing SLH-DSA hardware, all while maintaining a compact area footprint of 6K to 15K LUTs. This makes it the fastest SHA-2-based SLH-DSA implementation to date. With an optimized balance of area and performance, SPHINCSLET can assist resource-constrained devices in transitioning to post-quantum cryptography.},
note = {Just Accepted},
journal = {ACM Trans. Embed. Comput. Syst.},
month = apr,
keywords = {Post-Quantum Cryptography, PQC, Digital Signatures, SPHINCS+, SLH-DSA}
}
