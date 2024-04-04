import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const GlyphGraphModule = buildModule("GlyphGraph", (m) => {
  const gg = m.contract("GlyphGraph");
  return { gg };
});

export default GlyphGraphModule;
