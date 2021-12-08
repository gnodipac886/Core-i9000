# Core-i9000

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#advanced-features">Advanced Features</a></li>
    <li><a href="#run-times">Run Times</a></li>
    <li><a href="#acknowledgements">Acknowledgements</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project
This project is the final project for ECE 411 at UIUC. As a result of all the advanced features, we received a total score of 146/120. 

For more information, please refer to our [final report](https://github.com/gnodipac886/Core-i9000/blob/superscalar/ECE%20411%20MP4%20Report.pdf) and our [final presentation](https://github.com/gnodipac886/Core-i9000/blob/superscalar/ECE%20411%20MP4%20Final%20Presentation.pdf).

We decided to implement an 32 bit out-of-order RISC-V processor based
on the Tomasulo algorithm learned in lecture. The goal was to have a fully functional processor
that supports the RV32i ISA. After implementing the base CPU from scratch, we also included
various advanced features such as dynamic branch prediction, superscalar processing,
prefetching, as well as a N-way L1 cache and a unified L2 cache.

In order to help us verify the processor and obtain metrics in order to expose bottlenecks,
we developed our own software processor model that is capable of running assembly code
autonomously. Not only could the software model independently run programs, we also
programmed it such that it can report metrics such as the number of instructions per cycle and
branch prediction accuracy. By using this feature in the software model, we were able to learn
what was limiting our CPU and pick the proper advanced feature to implement that can best
improve performance.

The reason we decided to implement an out-of-order processor is because we wanted to
challenge ourselves and attempt to put the concepts we learned into practice. By building the
processor, we can also explore different optimization techniques that may particularly benefit the
out-of-order architecture.

![CPU Design](https://github.com/gnodipac886/Core-i9000/blob/superscalar/design/CPU_diagram.png)
<p align="center">
  <img src="https://github.com/gnodipac886/Core-i9000/blob/superscalar/design/advanced_features_design.png">
</p>

<!-- Advanced Features -->
## Advanced Features
- Tomasulo
- Superscalar
- Local Branch Prediction
- Parameterized (N-Way) Cache
- L2 Cache
- Software Verification Model
- Hardware Prefetcher
- M-extension (Updated Nov 2021)

<!-- Run Times -->
## Run Times
With all the advanced features combined, we achieved the following times:
| Competition Code      | Run Time | Percentage Above Baseline|
| ----------- | ----------- | ----------- |
| Comp1   | 433,225 ns  | 39.89% |
| Comp2   | 136,695 ns  | 96.98% |
| Comp3   | 419,305 ns  | 88.48% |

<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
- Eric Dong - ericd3@illinois.edu
- Michael Kwan - mk26@illinois.edu
- Srikar Nalamalapu - svn3@illinois.edu
