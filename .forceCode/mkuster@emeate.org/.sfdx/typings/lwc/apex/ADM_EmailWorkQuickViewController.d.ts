declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.findWork" {
  export default function findWork(param: {workName: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.getSourceControlStatuses" {
  export default function getSourceControlStatuses(param: {workId: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.getSourceControlStatus" {
  export default function getSourceControlStatus(param: {workId: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.getTeamMembers" {
  export default function getTeamMembers(param: {teamId: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.getSprints" {
  export default function getSprints(param: {scrumTeamId: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.getWorkStatusList" {
  export default function getWorkStatusList(param: {workType: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.getBuilds" {
  export default function getBuilds(): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.setStatus" {
  export default function setStatus(param: {status: any, name: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.setAssignee" {
  export default function setAssignee(param: {assigneeId: any, workName: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.setQAEngineer" {
  export default function setQAEngineer(param: {qaId: any, workName: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.setSprint" {
  export default function setSprint(param: {sprintId: any, workName: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.setBuild" {
  export default function setBuild(param: {buildId: any, workName: any}): Promise<any>;
}
declare module "@salesforce/apex/ADM_EmailWorkQuickViewController.setSourceControl" {
  export default function setSourceControl(param: {sourceControlStatus: any, workName: any}): Promise<any>;
}
