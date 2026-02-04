pk_waystructures_1.0.0/
├── pack.mcmeta                    <-- version
└── data/
    ├── pk_waystructures/          <-- any name
    │   ├── function/...           <-- logic to spawn a pk_waystone in a structure
    │   ├── structure/...          <-- a group of blocks as an .nbt
    │   └── worldgen/              <-- settings to spawn the group of blocks as structure(s)
    │       ├── structure/...
    │       ├── structure_set/...
    │       └── template_pool/...
    └── minecraft/                 <-- specifically named to override / inject over vanilla settings
        ├── tags/
        │   └── function/
        │       └── tick.json      <-- tell minecraft to loop our code every tick
        └── worldgen/...           <-- settings to spawn the blocks as structure(s)