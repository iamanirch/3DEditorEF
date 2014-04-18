﻿<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title>TODO supply a title</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script>
            var fileName;
            var fileType;
            function func()
            {
                 fileName= document.getElementById("fileinput").value;
            }
            function func1()
            {
                document.getElementById("hidden").value= fileName;
     
            }
            
</script>
        </script>
    </head>
    <body>
        <form action="upload"  method="post" ENCTYPE='multipart/form-data' name="MyForm">
        Choose a file: <input type="file" id="fileinput" value="" name="file" onchange="func(this);"/>
        <script>
            var abc;
            function readSingleFile(evt) {
        var f = evt.target.files[0]; 

    if (f) {
      var r = new FileReader();
      r.onload = function(e) { 
	      var contents = e.target.result;
        abc= contents.substr(0, contents.indexOf("f"));
        document.getElementById("hidden1").value=abc;
      }
      r.readAsText(f);
    } else { 
      alert("Failed to load file");
    }
  }

  document.getElementById('fileinput').addEventListener('change', readSingleFile, false);
        </script>
        <input type="hidden" name="hidden" id="hidden" value=""/>
        <input type="hidden" name="hidden1" id="hidden1" value=""/>
        <input type="submit" onclick="func1()" />
        </form>
        <div id="canvas-drop" style="width:490px; margin:auto; position:relative; font-size: 9pt; color: #777777;">
            <canvas id="cv" style="border: 1px solid;" width="490" height="368" ></canvas>
			<div id="statistics" style="position:absolute; width:100px; height:50px; left:10px; top:10px; font:12px Courier New; color:red; background:transparent;"> </div>
			<div style="float:left;">
				<select id="model_list">
					<option>teapot.obj</option>
				</select>
				<button id="load" onclick="loadModel();">Load</button>
			</div>
			<div style="float:right;">
				<select id="render_mode_list">
					<option>render as points</option>
					<option>render as wireframe</option>
					<option>render as flat</option>
					<option>render as smooth</option>
					<option>render with environment</option> 
				</select>
				<button id="change" onclick="setRenderMode();">Change</button> 
			</div> <br> <br>
			<div style="align:left;">
				X=<input type="text" id="Oxmove_value" autocomplete="off" class="removeOnFocus" size="4"/> 
				Y=<input type="text" id="Oymove_value" autocomplete="off" class="removeOnFocus" size="4"/>
				Z=<input type="text" id="Ozmove_value" autocomplete="off" class="removeOnFocus" size="4"/>
				<button onclick="moveModel()"> Set Origin</button> <br><br>
				X=<input type="text" id="xmove_value" autocomplete="off" class="removeOnFocus" size="4"/> 
				Y=<input type="text" id="ymove_value" autocomplete="off" class="removeOnFocus" size="4"/> 
				Z=<input type="text" id="zmove_value" autocomplete="off" class="removeOnFocus" size="4"/>
				<button onclick="moveModel()"> Move</button> <br><br>
				X=<input type="text" id="xscale_value" autocomplete="off" class="removeOnFocus" size="4"/>
				Y=<input type="text" id="yscale_value" autocomplete="off" class="removeOnFocus" size="4"/> 
				Z=<input type="text" id="zscale_value" autocomplete="off" class="removeOnFocus" size="4"/>
				<button onclick="scaleModel()"> Scale</button> <br><br>
				X=<input type="text" id="xrot_value" autocomplete="off" class="removeOnFocus" size="4"/>
				Y=<input type="text" id="yrot_value" autocomplete="off" class="removeOnFocus" size="4"/>
				Z=<input type="text" id="zrot_value" autocomplete="off" class="removeOnFocus" size="4"/> 
				<button onclick="rotateModel()"> Rotate</button> 
			</div> <br><br> 
			<div style="align:right;">
				<input type="text" id="extrude" autocomplete="off" class="removeOnFocus" size="4"/> <button onclick="extrudePlane()"> Extrude </button>
				Select Planes
					<button name="myPlanes" onclick="planeExtractionX()">X-axis </button>
					<button name="myPlanes" onclick="planeExtractionY()">Y-axis </button>
					<button name="myPlanes" onclick="planeExtractionZ()">Z-axis </button> <br><br>
				<button onclick="resetScene()"> Reset </button> <button onclick="Test()"> Test </button> 
			</div>
        </div>
        <script type="text/javascript" src="js/jsc3d.js"></script>
        <script type="text/javascript" src="js/jsc3d.webgl.js"></script>
        <script type="text/javascript" src="js/jsc3d.touch.js"></script>
        <script type="text/javascript" src="js/jsc3d.ctm.js"></script>
        <script type="text/javascript" src="js/jsc3d.console.js"></script>
	<script type="text/javascript" src="http://code.jquery.com/jquery-1.7.1.min.js"></script>
        <script type="text/javascript">

			$(document).ready(function(){
                            
				$('.removeOnFocus').each(function() { 
					this.data = new Object(); 
					this.data.value = this.value; 
					$(this).focus(function(){
						if (this.value == this.data.value) this.value = ''; 
					}); 
					$(this).blur(function(){ 
						if (this.value == '') this.value = this.data.value; 
					}); 
				}); 
			});

			// comparing two arrays function
			Array.prototype.compare = function (array) {
				if (this[0] == array[0] && this[1] == array[1] && this[2] == array[2])
					return true;
				else
					return false;
			};
			
			// comparing two arrays function
			Array.prototype.compareObj = function (object) {
				if (this[0] == object.x && this[1] == object.y && this[2] == object.z)
					return true;
				else
					return false;
			};			
			
			// matrix multiplication of two matrix arrays
			Array.prototype.multiply = function(array) { 
				var result = [];
				for(var i = 0; i < this.length; i++) {
					result[i] = [];
					for(var k = 0; k < array[0].length; k++) {
						var sum = 0;
						for(var j = 0; j < array.length; j++) {
							sum += this[i][j] * array[j][k];
						}
						result[i].push(sum);
					}
				}
				return result;
			};
			
			// Return unique values inside array
			Array.prototype.getUnique = function(){
				var u = {}, a = [];
				for(var i = 0, l = this.length; i < l; ++i){
					if(u.hasOwnProperty(this[i])) {  	// hasOwnProperty returns true when there is a property exisitng in the object
					continue;
				}
				a.push(this[i]);
				u[this[i]] = 1;
				}
				return a;
			};			
            //initial parameters set for 3d model
            var canvas = document.getElementById('cv');
            var viewer = new JSC3D.Viewer(canvas);
            var logoTimerID = 0;
            viewer.setParameter('SceneUrl', 'Model/${requestScope["f2"]}');
            viewer.setParameter('InitRotationX', -45);
            viewer.setParameter('InitRotationY', 30); // -45 30 30
            viewer.setParameter('InitRotationZ', 30);
            viewer.setParameter('ModelColor', '#CAA618');
            viewer.setParameter('BackgroundColor1', '#000000');
            viewer.setParameter('BackgroundColor2', '#6A6AD4');
            viewer.setParameter('RenderMode', 'flat');
            viewer.setParameter('Renderer', 'webgl');
	    viewer.setParameter('ProgressBar', 'on');
            viewer.init();
            viewer.update();
			
			alert('Hello');
			var scene = viewer.getScene();
			if(scene && scene.getChildren().length > 0) {
				var meshOld = scene.getChildren();	
			}
			else {
				document.getElementById('statistics').innerHTML = 'No Loaded Mesh';
			}

			/*
			 * Show our user-defined progress indicator in loading.
             */
			// show statistics of current model when loading is completed				
				var totalFaceCount = 0;
				var totalVertexCount = 0
				for(var i=0; i<meshOld.length; i++) {
					totalFaceCount += meshOld[i].faceCount;
					totalVertexCount += meshOld[i].vertexBuffer.length / 3;
				} 
				var stats = totalVertexCount.toString() + ' vertices' + '<br/>' + totalFaceCount.toString() + ' facets';
				document.getElementById('statistics').innerHTML = stats;

				
			// Declaration of various variables
            [normalList, indexList, vertexList] = MeshToList(meshOld[0]);
            var XPlane = initMesh(); var YPlane = initMesh(); var ZPlane = initMesh();
			var indexXPlane = []; 	 var indexYPlane = [];	  var indexZPlane = [];
			var extrudeArray = [];
			var userNormal = {};
			
			// Plane segregation from model list
			for (var k = 0; k < normalList.length; k++){
				var I1 = indexList[k][0];
                var I2 = indexList[k][1];
                var I3 = indexList[k][2];
				
                if (normalList[k].compare([1,0,0]) /*|| normalList[k].compareObj([ -1, 0, 0])*/){
					XPlane.faceNormalBuffer.push(normalList[k]);
					XPlane.indexBuffer.push(I1);
					XPlane.indexBuffer.push(I2);
					XPlane.indexBuffer.push(I3);
					XPlane.indexBuffer.push(-1);
				}
                if (normalList[k].compare([0,1,0]) /*|| normalList[k].compareObj([ 0, -1, 0])*/){
					YPlane.faceNormalBuffer.push(normalList[k]);
					YPlane.indexBuffer.push(I1);
					YPlane.indexBuffer.push(I2);
					YPlane.indexBuffer.push(I3);
					YPlane.indexBuffer.push(-1);
				}
				if (normalList[k].compare([0,0,1]) /*|| normalList[k].compareObj([ 0, 0, -1])*/){
					ZPlane.faceNormalBuffer.push(normalList[k]);
					ZPlane.indexBuffer.push(I1);
					ZPlane.indexBuffer.push(I2);
					ZPlane.indexBuffer.push(I3);
					ZPlane.indexBuffer.push(-1);
				}
			}

//--------------------------------------------------------------------------------------------------------------------------------------------------
//		FUNCTIONS START HERE
//--------------------------------------------------------------------------------------------------------------------------------------------------

			// Extracting Planes from Model
			function planeExtraction(){
				var temp = [];
				var planeDistance = [];
				if([1,0,0].compareObj(userNormal)){
					var temp = XPlane.indexBuffer;
				}
				if([0,1,0].compareObj(userNormal)){
					var temp = YPlane.indexBuffer;
				}
				if([0,0,1].compareObj(userNormal)){
					var temp = ZPlane.indexBuffer;
				}
				temp = temp.getUnique();
				temp.splice(temp.indexOf(-1),1); 
				
				for(var i=0; i < temp.length; i++){
					planeDistance.push(constPlane(temp[i],userNormal));
				}
				
				planeDistance = planeDistance.getUnique();
				planeDistance.sort(function(a,b){return a-b}); 				// sorting numbers in an array
				
				alert("No. of planes along selected normal: "+planeDistance.length);
				var planeValue = prompt("Enter any one value from 1 to "+(planeDistance.length)+"\nAscending order of Planes from origin");
				extrudeArray = [];
				for(var i=0; i < temp.length; i++){
					if(planeDistance[planeValue-1] == constPlane(temp[i],userNormal)){
						extrudeArray.push(temp[i]);
					}
				}
			}			
			function planeExtractionX(){
				userNormal = {x:1,y:0,z:0};
				planeExtraction();
			}
			function planeExtractionY(){
				userNormal = {x:0,y:1,z:0}
				planeExtraction();
			}
			function planeExtractionZ(){
				userNormal = {x:0,y:0,z:1}
				planeExtraction();
			}
			
			//Extrusion of a single Plane specified by userNormal
			function extrudePlane(){
				var ext = parseFloat(document.getElementById("extrude").value);
			//	console.log(a);
				for(var i=0; i< extrudeArray.length; i++){
					if([1,0,0].compareObj(userNormal))
						vertexList[extrudeArray[i]][0] += ext;
					if([0,1,0].compareObj(userNormal))
						vertexList[extrudeArray[i]][1] += ext;
					if([0,0,1].compareObj(userNormal))
						vertexList[extrudeArray[i]][2] += ext;	
				}
				newRender(vertexList);
			}
			
			// Return constant value D from equation of plane
			function constPlane(index, normal){
				var constant = normal.x * vertexList[index][0] + normal.y * vertexList[index][1] + normal.z * vertexList[index][2];
				var dist = constant/Math.sqrt(Math.pow(normal.x,2)+Math.pow(normal.y,2)+Math.pow(normal.z,2));
				return dist;
			}

			//Find out the Max dimensions of the model
			function printGeometry(){
				var mama = meshOld[0].vertexBuffer;
                var kaka = meshOld[0].faceNormalBuffer;
                var nana = meshOld[0].indexBuffer;
                document.getElementById("printvertex").innerHTML = mama;
                document.getElementById("printnormal").innerHTML = kaka;
                document.getElementById("printindex").innerHTML = nana;
			}

			//Scaling model with user input
			function scaleModel(){
				var Sx = parseFloat(document.getElementById("xscale_value").value);
                var Sy = parseFloat(document.getElementById('yscale_value').value);
                var Sz = parseFloat(document.getElementById('zscale_value').value);
                if (isNaN(Sx)){Sx = 1; }	if (isNaN(Sy)){Sy = 1; }	if (isNaN(Sz)){Sz = 1; }

				for (var i = 0; i < vertexList.length; i++){
					vertexList[i][0] = vertexList[i][0] * Sx;
					vertexList[i][1] = vertexList[i][1] * Sy;
					vertexList[i][2] = vertexList[i][2] * Sz;
				}
				newRender(vertexList);
			}

			//Moving model with user input
			function moveModel(){
				var Mx = parseFloat(document.getElementById('xmove_value').value);
                var My = parseFloat(document.getElementById('ymove_value').value);
                var Mz = parseFloat(document.getElementById('zmove_value').value);
                var Ox = parseFloat(document.getElementById('Oxmove_value').value);
                var Oy = parseFloat(document.getElementById('Oymove_value').value);
                var Oz = parseFloat(document.getElementById('Ozmove_value').value);
                
				if (isNaN(Mx)){Mx = 0; }	if (isNaN(My)){My = 0; }	if (isNaN(Mz)){Mz = 0; }
				if (isNaN(Ox)){Ox = 0; }	if (isNaN(Oy)){Oy = 0; }	if (isNaN(Oz)){Oz = 0; }

				for (var i = 0; i < vertexList.length; i++){
					vertexList[i][0] = vertexList[i][0] + Mx - Ox;
					vertexList[i][1] = vertexList[i][1] + My - Oy;
					vertexList[i][2] = vertexList[i][2] + Mz - Oz;
				}
				newRender(vertexList);
			}

			// Rotating model with user inputs
			function rotateModel(){
				var pi = Math.PI;
				//angle in radians entered by user
				var Ax = pi * (parseFloat(document.getElementById('xrot_value').value) / 180 );
				var Ay = pi * (parseFloat(document.getElementById('yrot_value').value) / 180 ); 
				var Az = pi * (parseFloat(document.getElementById('zrot_value').value) / 180 );

				var I = [[1,0,0],[0,1,0],[0,0,1]];
				var Rx = [[1,0,0],
						  [0,parseFloat( Math.cos(Ax).toFixed(3)), parseFloat(Math.sin(Ax).toFixed(3))],
						  [0,parseFloat(-Math.sin(Ax).toFixed(3)), parseFloat(Math.cos(Ax).toFixed(3))]];
						  
				var Ry = [[parseFloat(Math.cos(Ay).toFixed(3)), 0, parseFloat(-Math.sin(Ay).toFixed(3))],
						  [0, 1, 0],
						  [parseFloat(Math.sin(Ay).toFixed(3)), 0, parseFloat(Math.cos(Ay).toFixed(3))]];
						  
				var Rz = [[parseFloat(Math.cos(Az).toFixed(3)) , parseFloat(Math.sin(Az).toFixed(3)), 0],
						  [parseFloat(-Math.sin(Az).toFixed(3)), parseFloat(Math.cos(Az).toFixed(3)), 0],
						  [0, 0, 1]];
						 
				//Rx, Ry, Rz are rotation 3*3 matrices to be multiplied with vertex arrays.
				if (isNaN(Ax)){Rx = I;}
				if (isNaN(Ay)){Ry = I;}	
				if (isNaN(Az)){Rz = I;}

				var XRotated =   vertexList.multiply(Rx); 
				var XYRotated =  XRotated.multiply(Ry); 
				var XYZRotated = XYRotated.multiply(Rz); 
				vertexList = XYZRotated; 

				var nXRotated =   normalList.multiply(Rx);
				var nXYRotated =  nXRotated.multiply(Ry);
				var nXYZRotated = nXYRotated.multiply(Rz);
				normalList = nXYZRotated;

				newRender(vertexList,normalList);
			}

			// Render new scene with modified arrays
			function newRender(vertexnew, normalnew){
				var meshNew = initMesh();
				// Topology not changing
				meshNew.indexBuffer = meshOld[0].indexBuffer; 
				//VertexList conversion
				for (var i = 0; i < vertexnew.length; i++){
					meshNew.vertexBuffer.push(vertexnew[i][0]);
					meshNew.vertexBuffer.push(vertexnew[i][1]);
					meshNew.vertexBuffer.push(vertexnew[i][2]);
				}
				//NormalList conversion
				if (isNaN(normalnew)){ meshNew.faceNormalBuffer = meshOld[0].faceNormalBuffer; 
				}
				else{ meshNew.faceNormalBuffer = normalnew; 
				}
				meshNew.init();
                newScene(meshNew);
			}

			//Creates entirely different new scene in the viewer. Replacing the old one
			function newScene(mesh){
				var sceneN = new JSC3D.Scene();
                sceneN.addChild(mesh);
                viewer.replaceScene(sceneN);
                viewer.update();
			}

			//Resets to the original scene in the viewer
			function resetScene(){
				[normalList, indexList, vertexList] = MeshToList(meshOld[0]);
				viewer.replaceScene(scene);
                viewer.resetScene();
                viewer.update();
			}

			// Convert and Return to 2-dim arrays
			function MeshToList(mesh){
				var NList = [];
                var IList = [];
                var VList = [];
                for (var i = 0; i < (mesh.indexBuffer.length / 4); i++){
					NList[i] = new Array();
					NList[i][0] = mesh.faceNormalBuffer[ i * 3    ];
					NList[i][1] = mesh.faceNormalBuffer[(i * 3) + 1];
					NList[i][2] = mesh.faceNormalBuffer[(i * 3) + 2];
					IList[i] = new Array();
					IList[i][0] = mesh.indexBuffer[ i * 4    ];
					IList[i][1] = mesh.indexBuffer[(i * 4) + 1];
					IList[i][2] = mesh.indexBuffer[(i * 4) + 2];
				//	IList[i][3] = mesh.indexBuffer[(i * 4) + 3];
					if (i < (mesh.vertexBuffer.length) / 3){
						VList[i] = new Array();
						VList[i][0] = mesh.vertexBuffer[ i * 3    ];
						VList[i][1] = mesh.vertexBuffer[(i * 3) + 1];
						VList[i][2] = mesh.vertexBuffer[(i * 3) + 2];
					}
				}
				return [NList, IList, VList];
			}

			//Convert 2D List and return Mesh data structure
			function ListToMesh(NList, IList, VList){
				var meshrand = initMesh();
                for (var i = 0; i < VList.length; i++){
					meshrand.vertexBuffer.push(VList[i][0]);
					meshrand.vertexBuffer.push(VList[i][1]);
					meshrand.vertexBuffer.push(VList[i][2]);
				}
				for (var i = 0; i < NList.length; i++){
					meshrand.faceNormalBuffer.push(NList[i][0]);
					meshrand.faceNormalBuffer.push(NList[i][1]);
					meshrand.faceNormalBuffer.push(NList[i][2]);
				}
				meshrand.indexBuffer = IList;
                return meshrand;
			}

			//Creates new mesh on being called
			function initMesh(){
				var mesh = new JSC3D.Mesh;
                mesh.vertexBuffer = [];
                mesh.indexBuffer = [];
                mesh.faceNormalBuffer = [];
                return mesh;
			}
			
			//setting render mode of model
			function setRenderMode() {
				if(logoTimerID > 0)
					return;
				var modes = document.getElementById('render_mode_list');
				switch(modes.selectedIndex) {
				case 0:
					viewer.setRenderMode('point');
					JSC3D.console.logInfo('Set to point mode.');
					break;
				case 1:
					viewer.setRenderMode('wireframe');
					JSC3D.console.logInfo('Set to wireframe mode.');
					break;
				case 2:
					viewer.setRenderMode('flat');
					JSC3D.console.logInfo('Set to flat mode.');
					break;
				case 3:
					viewer.setRenderMode('smooth');
					JSC3D.console.logInfo('Set to smooth mode.');
					break;
				case 4:
					viewer.setRenderMode('texturesmooth');
					var scene = viewer.getScene();
					if(scene) {
						var objects = scene.getChildren();
						for(var i=0; i<objects.length; i++)
							objects[i].isEnvironmentCast = true;
					}
					JSC3D.console.logInfo('Set to environment-mapping mode.');
					break;
				default:
					viewer.setRenderMode('flat');
					break;
				}
				viewer.update();
			}
			
        </script>
    </BODY>
</HTML>