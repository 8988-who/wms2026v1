import { useUserStore } from "@/store";
import { ROLE_ROOT, PERM_ALL } from "@/constants";

type AccessType = "perm" | "role";
type CheckMode = "some" | "every";

function checkAccess(type: AccessType, keys: string | string[], mode: CheckMode = "some"): boolean {
  if (!keys) return false;

  const keyArray = Array.isArray(keys) ? keys : [keys];
  if (keyArray.length === 0) return false;

  const userInfo = useUserStore().userInfo;
  if (!userInfo) return false;

  const { roles = [], perms = [] } = userInfo;

  if (roles.includes(ROLE_ROOT)) return true;

  if (type === "perm" && keyArray.includes(PERM_ALL)) return true;

  const userKeys = type === "perm" ? perms : roles;
  if (!userKeys || userKeys.length === 0) return false;

  return keyArray[mode]((key) => userKeys.includes(key));
}

export function hasPermission(perm: string | string[]): boolean {
  return checkAccess("perm", perm, "some");
}

export function hasRole(role: string | string[]): boolean {
  return checkAccess("role", role, "some");
}

export function hasAllPermissions(perms: string | string[]): boolean {
  return checkAccess("perm", perms, "every");
}

export function hasAllRoles(roles: string | string[]): boolean {
  return checkAccess("role", roles, "every");
}
