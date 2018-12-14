public class AgileManager_InstallDataException extends AgileManager_InstallException{
    public override void handle(InstallContext context){
        //Printing exp.getMessage() no custom data 
        System.debug(this.getMessage());
    }
}