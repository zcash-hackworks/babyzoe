# Baby ZoE - first step towards Zerocash over Ethereum

* We've changed Parity to support a snark precompile: https://github.com/gancherj/parity/commit/b820abf755e216ccf24640549735412ec02dac62

* We've created an Ethereum contract: `zoe/contract/`

* We've implemented a primitive mixing circuit: https://github.com/ebfull/hackishlibsnarkbindings and bindings to libsnark for SNARK verification in Rust.

For more details, see our [blog post](https://z.cash/blog/zksnarks-in-ethereum.html) and presentation slides (in [PDF](talks/2016-07-27-IC3---SNARKs-for-Ethereum.pdf) or [OpenDocument Presentation](talks/2016-07-27-IC3---SNARKs-for-Ethereum.odp) format).
