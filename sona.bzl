UTILS = [
    "//utils/osgiwrap:osgi-jar",
    "//utils/osgi:onlab-osgi",
    "//utils/junit:onlab-junit",
    "//utils/misc:onlab-misc",
    "//utils/rest:onlab-rest",
]

API = [
    "//core/api:onos-api",
]

CORE = UTILS + API + [
    "//core/net:onos-core-net",
    "//core/common:onos-core-common",
    "//core/store/primitives:onos-core-primitives",
    "//core/store/serializers:onos-core-serializers",
    "//core/store/dist:onos-core-dist",
    "//core/store/persistence:onos-core-persistence",
    "//cli:onos-cli",
    "//protocols/openflow/api:onos-protocols-openflow-api",
    "//protocols/openflow/ctl:onos-protocols-openflow-ctl",
    "//protocols/ovsdb/rfc:onos-protocols-ovsdb-rfc",
    "//protocols/ovsdb/api:onos-protocols-ovsdb-api",
    "//protocols/ovsdb/ctl:onos-protocols-ovsdb-ctl",
    "//protocols/p4runtime/api:onos-protocols-p4runtime-api",
    "//protocols/p4runtime/model:onos-protocols-p4runtime-model",
    "//drivers/utilities:onos-drivers-utilities",
    "//providers/openflow/device:onos-providers-openflow-device",
    "//providers/openflow/packet:onos-providers-openflow-packet",
    "//providers/openflow/flow:onos-providers-openflow-flow",
    "//providers/openflow/group:onos-providers-openflow-group",
    "//providers/openflow/meter:onos-providers-openflow-meter",
    "//providers/ovsdb/device:onos-providers-ovsdb-device",
    "//providers/ovsdb/tunnel:onos-providers-ovsdb-tunnel",
    "//providers/rest/device:onos-providers-rest-device",
    "//providers/general/device:onos-providers-general-device",
    "//web/api:onos-rest",
]

ONOS_DRIVERS = [
    # Drivers
    "//drivers/default:onos-drivers-default-oar",
    "//drivers/ovsdb:onos-drivers-ovsdb-oar",
]

ONOS_PROVIDERS = [
    # Providers
    "//providers/host:onos-providers-host-oar",
    "//providers/lldp:onos-providers-lldp-oar",
    "//providers/openflow/message:onos-providers-openflow-message-oar",
    "//providers/ovsdb:onos-providers-ovsdb-oar",
    "//providers/ovsdb/host:onos-providers-ovsdb-host-oar",
    "//providers/ovsdb/base:onos-providers-ovsdb-base-oar",
    "//providers/null:onos-providers-null-oar",
    "//providers/openflow/base:onos-providers-openflow-base-oar",
    "//providers/openflow/app:onos-providers-openflow-app-oar",
    "//providers/general:onos-providers-general-oar",
]

ONOS_APPS = [
    "//apps/optical-model:onos-apps-optical-model-oar",
    "//apps/tunnel:onos-apps-tunnel-oar",
    "//web/gui2:onos-web-gui2-oar",
]

SONA_APPS = [
    "//apps/openstacknode:onos-apps-openstacknode-oar",
    "//apps/openstacknetworking:onos-apps-openstacknetworking-oar",
    "//apps/openstacknetworkingui:onos-apps-openstacknetworkingui-oar",
    "//apps/openstacktelemetry:onos-apps-openstacktelemetry-oar",
    "//apps/openstacktroubleshoot:onos-apps-openstacktroubleshoot-oar",
    "//apps/openstackvtap:onos-apps-openstackvtap-oar",
]

FEATURES = [
    "//tools/package/features:onos-thirdparty-base",
    "//tools/package/features:onos-thirdparty-web",
    "//tools/package/features:onos-api",
    "//tools/package/features:onos-core",
    "//tools/package/features:onos-cli",
    "//tools/package/features:onos-rest",
]

APPS = ONOS_DRIVERS + ONOS_PROVIDERS + ONOS_APPS + SONA_APPS
