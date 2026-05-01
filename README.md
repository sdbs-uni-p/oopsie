# Oopsie 🫢🫣

Artifacts for the VLDB 2027 submission "Static Type Checking for Database Access Code"

Under construction 🏗️

## Overview

This repository contains the source code of the _Oopsie_ checker (f.k.a. OPSC) and the artifacts to reproduce the results of the paper's experiments.
These include the source code or patches for the example projects used in the paper, and the scripts to run the experiments.

**_Todo: Results/reports/charts/..._**

## Example projects

The projects used in the paper are located in `projects/`.
For the handwritten test cases, and the O'Reilly: bank project, the source code is provided.
For the remaining projects (java-design-pattern, JDBC-Course, OSCAR, OpenNMS and EscadaTPC-C), we provide scripts that download the source code and apply the necessary patches to compile the code with the _Oopsie_ checker, with manual type annotations if applicable.


## Experiments

### Requirements

* Docker, Docker Compose
* ?

### [Name?] experiment

This experiment compiles all projects with the _Oopsie_ checker once (ad-hoc analysis); OSCAR and OpenNMS are additionally compiled with manual type annotations.

#### How to run

```
./start.sh
```

Expected run time: [???]

#### Steps

* Download and patch the projects
* Build the Docker image (the following steps are executed inside the Docker container)
* Compile _Oopsie_ (OPSC)
* Compile the projects with the checker
* Collect and process the results

> [!NOTE]
> For OpenNMS, additional project dependencies will be compiled before the module to be checked is compiled (displayed as `Running prerun.sh`). This should take around ??? minutes.
> OSCAR, which consists of a Maven project and a Gradle project, has the longest compilation time at around ??? minutes.

#### Results

The experiment will produce the following artifacts:
* [Should we even mention this?] `data/{project}_run/cleaned_statements.csv` - A CSV file containing information on the statements processed by the checker (including unsupported ones).
* [Should we even mention this?] `data/{project}_run/cleaned_bindings.csv` - A CSV file containing information on the getters and setters processed by the checker.
* [Split and make closer to the paper?] `data/summary.csv` – Statistics on the statements, getters and setters found in each project, as well as aggregated checker results, as shown in Tables 2 and 3 and Figures 4--6 in the paper.
* [Missing]: TP getter/setter types (for OSCAR), as shown in Figure 5. 

### Performance experiment

Compile each project five times, also without any checker, and additionally OSCAR and OpenNMS with the Value Checker, but without _Oopsie_.

#### How to run

```
./start_performance.sh
```

[Todo]
