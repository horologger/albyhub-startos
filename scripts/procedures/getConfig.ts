// To utilize the default config system built, this file is required. It defines the *structure* of the configuration file. These structured options display as changeable UI elements within the "Config" section of the service details page in the StartOS UI.

import { compat, types as T } from "../deps.ts";

export const getConfig: T.ExpectedExports.getConfig = compat.getConfig({
  "tor-address": {
    name: "Tor Address",
    description: "The Tor address of the network interface",
    type: "pointer",
    subtype: "package",
    "package-id": "albyhub",
    target: "tor-address",
    interface: "main",
  },

  lightning: {
    name: "Lightning Implementation",
    description:
      "Choose the Lightning implementation to use with Alby Hub.<br><br><strong>LND on this node</strong>: Use the LND (Lightning Network Daemon) implementation. This is the more sovereign and secure option, allowing full control over your node.<br><br><strong>Alby embedded node (LDK)</strong>: Use the built-in Lightning Development Kit (LDK) implementation. This option is convenient but offers less control over your node.",
    type: "enum",
    values: ["lnd", "alby"],
    "value-names": {
      lnd: "LND on this node",
      alby: "Alby embedded node (LDK)",
    },
    default: "lnd",
    // "warning": "The Alby embedded node (LDK) is a convenient starting option, but for increased sovereignty and security, it's recommended to switch to LND when possible."
  },
});
