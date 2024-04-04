import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const GlyphGraphModule = buildModule("GlyphGraph", (m) => {
  console.log(process.argv)
  const gg = m.contract("GlyphGraph");
  return { gg };
});

export default GlyphGraphModule;
