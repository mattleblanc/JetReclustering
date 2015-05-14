# xAODJetReclustering

This tool allows you to recluster small-R xAOD jets into large-R xAOD jets. It provides configurable filtering of the small-R jets, reclustering using standard or variable-R algorithms, configurable trimming of the large-R jets, and jet moment & jet substructure moment calculations.

If you would like to get involved, see the twiki for [the JetMET working group for jet reclustering](https://twiki.cern.ch/twiki/bin/view/AtlasProtected/JetReclustering).

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Installing](#installing)
- [Configurations for](#configurations-for)
  - [`JetReclusteringTool` tool](#jetreclusteringtool-tool)
  - [`JetReclusteringAlgo` algorithm](#jetreclusteringalgo-algorithm)
- [Using xAOD Jet Reclustering](#using-xaod-jet-reclustering)
  - [Incorporating in existing code](#incorporating-in-existing-code)
  - [Incorporating in algorithm chain](#incorporating-in-algorithm-chain)
- [Studies and Example Usage](#studies-and-example-usage)
  - [Accessing the subjets from constituents](#accessing-the-subjets-from-constituents)
- [Authors](#authors)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installing
The last stable analysis base used is **2.1.30**. To install,
```bash
git clone https://github.com/kratsg/xAODJetReclustering.git
rc find_packages
rc compile
```

## Configurations for

### `JetReclusteringTool` tool

 Property           | Type      | Default           | Description
:-------------------|:---------:|------------------:|:-------------------------------------------------------------------------------------
InputJetContainer   | string    |                   | name of the input jet container for reclustering
OutputJetContainer  | string    |                   | name of the output jet container holding reclustered jets
InputJetPtMin       | float     | 25.0              | filter input jets by requiring a minimum pt cut [GeV]
ReclusterAlgorithm  | string    | antikt_algorithm  | name of algorithm for clustering large-R jets
ReclusterRadius     | float     | 1.0               | radius of large-R reclustered jets
RCJetPtMin          | float     | 50.0              | filter reclustered jets by requiring a minimum pt cut [GeV]
RCJetPtFrac         | float     | 0.05              | trim the reclustered jets with a PtFrac on its constituents (eg: small-R input jets)
VariableRMinRadius  | float     | -1.0              | minimum radius for variable-R jet finding
VariableRMassScale  | float     | -1.0              | mass scale [GeV] for variable-R jet finding

Variable-R jet finding is performed if `VariableRMinRadius >= 0` and `VariableRMassScale >= 0`.

### `JetReclusteringAlgo` algorithm

As well as the provided above configurations for the `JetReclusteringTool`, we also provide a `m_debug` configuration for extra verbose output and an `m_outputXAODName` to create an output xAOD containing the reclustered jets (note: experimental)

Variable            | Type      | Default           | Description
:-------------------|:---------:|------------------:|:-------------------------------------------------------------------------------------
m_inputJetContainer | string    |                   | see above
m_outputJetContainer| string    |                   | see above
m_ptMin_input       | float     | 25.0              | see above
m_rc_algName        | string    | antikt_algorithm  | see above
m_radius            | float     | 1.0               | see above
m_ptMin_rc          | float     | 50.0              | see above
m_ptFrac            | float     | 0.05              | see above
m_varR_minR         | float     | -1.0              | see above
m_varR_mass         | float     | -1.0              | see above
m_outputXAODName    | string    |                   | if defined, put the reclustered jets in an output xAOD file of the given name
m_debug             | bool      | false             | enable verbose debugging information, such as printing the tool configurations

## Using xAOD Jet Reclustering

### Incorporating in existing code

If you wish to incorporate `xAODJetReclustering` directly into your code, add this package as a dependency in `cmt/Makefile.RootCore` and then a header

```c++
#include <xAODJetReclustering/JetReclusteringTool.h>
```

to get started. At this point, you can set up your standard tool in the `initialize()` portion of your algorithm as a pointer

```c++
m_jetReclusteringTool = new JetReclusteringTool(m_name);
RETURN_CHECK(m_jetReclusteringTool->setProperty("InputJetContainer",  m_inputJetContainer));
RETURN_CHECK(m_jetReclusteringTool->setProperty("OutputJetContainer", m_outputJetContainer));
RETURN_CHECK(m_jetReclusteringTool->setProperty("ReclusterRadius",    m_radius));
RETURN_CHECK(m_jetReclusteringTool->setProperty("ReclusterAlgorithm", m_rc_alg));
RETURN_CHECK(m_jetReclusteringTool->setProperty("InputJetPtMin",      m_ptMin_input));
RETURN_CHECK(m_jetReclusteringTool->setProperty("RCJetPtMin",         m_ptMin_rc));
RETURN_CHECK(m_jetReclusteringTool->setProperty("RCJetPtFrac",        m_ptFrac));
RETURN_CHECK(m_jetReclusteringTool->initialize());
```

and then simply call `m_jetReclusteringTool->execute()` in the `execute()` portion of your algorithm to fill the TStore with the appropriate container(s). Don't forget to delete the pointer when you're done.
```c++
if(m_jetReclusteringTool) delete m_jetReclusteringTool;
```

Note that as it behaves like an `AsgTool`, `setProperty()` and `initialize()` return `StatusCode` which needs to be checked.
```c++
#define RETURN_CHECK( CONTEXT, EXP, INFO )                                 \
   do {                                                                    \
      if( ! EXP.isSuccess() ) {                                            \
         ::Error( CONTEXT, XAOD_MESSAGE( "Failed to execute: %s\n\t%s\n" ),\
                  #EXP, INFO );                                            \
         return EL::StatusCode::FAILURE;                                   \
      }                                                                    \
   } while( false )
```

### Incorporating in algorithm chain

This is the least destructive option since it requires **no change** to your existing code. All you need to do is create a new `JetReclusteringAlgo` algorithm and add it to the job before other algorithms downstream that want access to the reclustered jets. It is highly configurable. In your runner macro, add the header

```c++
#include <xAODJetReclustering/JetReclusteringAlgo.h>
```

and then simply set up your algorithm like so

```c++
// initialize and set it up
JetReclustering* jetReclusterer = new JetReclusteringAlgo();
jetReclusterer->m_inputJetContainer = "AntiKt4LCTopoJets";
jetReclusterer->m_outputJetContainer = "AntiKt10LCTopoJetsRCAntiKt4LCTopoJets";
jetReclusterer->m_name = "R10"; // unique name for the tool
jetReclusterer->m_ptMin_input = 25.0; // GeV
jetReclusterer->m_ptMin_rc = 50.0; // GeV
jetReclusterer->m_ptFrac = 0.05; // GeV

// ...
// ...
// ...

// add it to your job sometime later
job.algsAdd(jetReclusterer);
```

## Studies and Example Usage

See [kratsg/ReclusteringStudies](https://github.com/kratsg/ReclusteringStudies) for studies and example usage.

### Accessing the subjets from constituents

The reclustered jets have constituents which are your input small-R jets. These can be re-inflated, so to speak. As an example, I wanted to get the btagging information of my subjets as well as their constituents (eg: the topological calorimeter clusters, `TopoCaloClusters`)

```c++
for(auto jet: *in_jets){
  const xAOD::Jet* subjet(nullptr);
  const xAOD::BTagging* btag(nullptr);
  for(auto constit: jet->getConstituents()){
    subjet = static_cast<const xAOD::Jet*>(constit->rawConstituent());
    btag = subjet->btagging();
    if(btag) Info("execute()", "btagging: %0.2f", btag->MV1_discriminant());

    for(auto subjet_constit: subjet->getConstituents()){
      Info("execute()", "\tconstituent pt: %0.2f", subjet_constit->pt());
    }
  }
}
```

where we explicitly `static_cast<>` our raw pointer from the `rawConstituent()` call. See [xAODJet/JetConstituentVector.h](http://acode-browser.usatlas.bnl.gov/lxr/source/atlas/Event/xAOD/xAODJet/xAODJet/JetConstituentVector.h) for more information about what is available. As a raw pointer, we already know that the input to the constituents were small-R jets (since we re-clustered ourselves) so this type of casting is safe.

## Authors
- [Giordon Stark](https://github.com/kratsg)
