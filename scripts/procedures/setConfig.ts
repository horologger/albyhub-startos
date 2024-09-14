// This is where any configuration rules related to the configuration would go. These ensure that the user can only create a valid config.

import { compat, types as T } from "../deps.ts";

// deno-lint-ignore require-await
export const setConfig: T.ExpectedExports.setConfig = async (
  effects: T.Effects,
  newConfig: T.Config
) => {
  // deno-lint-ignore no-explicit-any
  const dependsOnLND: { [key: string]: string[] } =
    (newConfig as any)?.lightning === "lnd" ? { lnd: [] } : {};

  // deno-lint-ignore no-explicit-any
  const dependsOnAlby: { [key: string]: string[] } =
    (newConfig as any)?.lightning === "alby" ? { alby: [] } : {};

  return compat.setConfig(effects, newConfig, {
    ...dependsOnLND,
    ...dependsOnAlby,
  });
};
